import { useEffect, useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { apiRequest, ApiError } from "../api/client";
import { useAuth } from "../context/AuthContext";
import type { Patient, Provider } from "../types";

export function BookAppointmentPage() {
  const { token } = useAuth();
  const navigate = useNavigate();

  const [providers, setProviders] = useState<Provider[]>([]);
  const [patients, setPatients] = useState<Patient[]>([]);
  const [providerId, setProviderId] = useState("");
  const [patientId, setPatientId] = useState("");
  const [startsAt, setStartsAt] = useState("");
  const [durationMinutes, setDurationMinutes] = useState(30);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    apiRequest<Provider[]>("/api/v1/providers", { token }).then(setProviders).catch(() => undefined);
    apiRequest<Patient[]>("/api/v1/patients", { token }).then(setPatients).catch(() => undefined);
  }, [token]);

  async function handleSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    setSubmitting(true);

    const starts = new Date(startsAt);
    const ends = new Date(starts.getTime() + durationMinutes * 60_000);

    try {
      await apiRequest("/api/v1/appointments", {
        method: "POST",
        token,
        body: {
          provider_id: Number(providerId),
          patient_id: Number(patientId),
          starts_at: starts.toISOString(),
          ends_at: ends.toISOString(),
        },
      });
      navigate("/");
    } catch (err) {
      if (err instanceof ApiError && err.status === 409) {
        setError("That provider is already booked for that time. Pick another slot.");
      } else {
        setError(err instanceof ApiError ? err.message : "Failed to book appointment");
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="page page-narrow">
      <h1>Book an appointment</h1>
      <form onSubmit={handleSubmit} className="card">
        <label>
          Provider
          <select value={providerId} onChange={(e) => setProviderId(e.target.value)} required>
            <option value="" disabled>
              Select a provider
            </option>
            {providers.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name} · {p.specialty}
              </option>
            ))}
          </select>
        </label>
        <label>
          Patient
          <select value={patientId} onChange={(e) => setPatientId(e.target.value)} required>
            <option value="" disabled>
              Select a patient
            </option>
            {patients.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name}
              </option>
            ))}
          </select>
        </label>
        <label>
          Start time
          <input type="datetime-local" value={startsAt} onChange={(e) => setStartsAt(e.target.value)} required />
        </label>
        <label>
          Duration (minutes)
          <input
            type="number"
            min={15}
            step={15}
            value={durationMinutes}
            onChange={(e) => setDurationMinutes(Number(e.target.value))}
          />
        </label>
        {error && <p className="error">{error}</p>}
        <button type="submit" disabled={submitting}>
          {submitting ? "Booking..." : "Book appointment"}
        </button>
      </form>
    </div>
  );
}
