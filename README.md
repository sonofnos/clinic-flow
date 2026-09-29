# Clinic Flow

A multi-provider clinic scheduling API (Rails 8, API-only) with a React/TypeScript
front end. Staff book patients against providers; providers can't be double-booked.

## What it does

- JWT auth (`POST /login`), roles: `admin`, `staff`, `provider`.
- Providers, patients, and appointments over a JSON API.
- Booking a slot (`POST /api/v1/appointments`) that's already taken returns
  `409 Conflict` instead of silently double-booking a provider.
- Cancelling an appointment frees the slot for rebooking.
- A reminder email is queued (Solid Queue/ActiveJob) 24h before each scheduled
  appointment.

## Double-booking, for real

A unique index can't express "no overlapping time range," so this is enforced
two ways:

1. **Application level**: `Appointment.book!` locks the provider row
   (`SELECT ... FOR UPDATE`) and checks for an overlapping active appointment
   inside the same transaction, before inserting.
2. **Database level**: a Postgres `EXCLUDE USING gist` constraint on
   `(provider_id, tsrange(starts_at, ends_at))` (`db/migrate/..._create_appointments.rb`),
   scoped to active (non-cancelled) appointments via `btree_gist`.

The row lock alone isn't enough — two requests on two different DB connections
can both pass the "is it free?" check before either commits. `spec/models/appointment_spec.rb`
has a regression test that fires two real bookings for the same slot from two
threads on two separate connections; exactly one wins, and the count of
scheduled appointments for that provider afterward is `1`.

## Stack

- Rails 8.1 (API-only), PostgreSQL, Solid Queue for background jobs.
- React 19 + TypeScript + Vite, React Router, plain `fetch`.
- RSpec + FactoryBot for tests.

## Running it

```
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server -p 3000

cd web
npm install
cp .env.example .env.local   # VITE_API_URL=http://localhost:3000
npm run dev
```

Seeded login: `admin@clinicflow.test` / `password123` (also seeds two
providers and three patients).

## Tests

```
bundle exec rspec
```

24 examples, including the double-booking concurrency test above.
