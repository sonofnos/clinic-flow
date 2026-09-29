import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { apiRequest, ApiError } from "../api/client";
import { useAuth } from "../context/AuthContext";
import type { Appointment } from "../types";

export function DashboardPage() {
  const { token, user, logout } = useAuth();
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  async function loadAppointments() {
    setLoading(true);
    try {
      const data = await apiRequest<Appointment[]>("/api/v1/appointments", { token });
      setAppointments(data);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to load appointments");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadAppointments();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function cancelAppointment(id: number) {
    const reason = window.prompt("Reason for cancelling (optional)") ?? "";
    try {
      await apiRequest(`/api/v1/appointments/${id}/cancel`, { method: "POST", body: { reason }, token });
      loadAppointments();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to cancel appointment");
    }
  }

  return (
    <div className="page">
      <header className="topbar">
        <h1>Clinic Flow</h1>
        <div>
          <span className="muted">
            {user?.name} · {user?.role}
          </span>
          <button onClick={logout} className="link-button">
            Sign out
          </button>
        </div>
      </header>

      <div className="actions">
        <Link to="/book" className="button">
          Book appointment
        </Link>
      </div>

      {error && <p className="error">{error}</p>}
      {loading ? (
        <p>Loading...</p>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>When</th>
              <th>Provider</th>
              <th>Patient</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {appointments.map((appt) => (
              <tr key={appt.id}>
                <td>{new Date(appt.starts_at).toLocaleString()}</td>
                <td>{appt.provider.name}</td>
                <td>{appt.patient.name}</td>
                <td>
                  <span className={`badge badge-${appt.status}`}>{appt.status}</span>
                </td>
                <td>
                  {appt.status === "scheduled" && (
                    <button onClick={() => cancelAppointment(appt.id)} className="link-button">
                      Cancel
                    </button>
                  )}
                </td>
              </tr>
            ))}
            {appointments.length === 0 && (
              <tr>
                <td colSpan={5} className="muted">
                  No appointments yet.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}
