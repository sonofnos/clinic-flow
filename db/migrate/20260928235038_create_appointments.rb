class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    enable_extension "btree_gist"

    create_table :appointments do |t|
      t.references :provider, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :status, null: false, default: 0
      t.string :cancellation_reason

      t.timestamps
    end

    add_index :appointments, [ :provider_id, :starts_at ]

    # Belt-and-braces against double-booking: even if two requests race past the
    # application-level row lock (e.g. a second app server, a retried request),
    # Postgres itself refuses to store two active appointments for the same
    # provider whose time ranges overlap. Cancelled/no-show slots are excluded
    # from the check so they can be rebooked freely.
    execute <<-SQL
      ALTER TABLE appointments
      ADD CONSTRAINT no_overlapping_active_appointments
      EXCLUDE USING gist (
        provider_id WITH =,
        tsrange(starts_at, ends_at) WITH &&
      ) WHERE (status IN (0, 1))
    SQL
  end
end
