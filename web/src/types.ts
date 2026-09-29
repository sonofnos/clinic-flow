export type Role = "admin" | "staff" | "provider";

export interface AuthUser {
  id: number;
  name: string;
  email: string;
  role: Role;
}

export interface Provider {
  id: number;
  name: string;
  specialty: string;
  bio: string | null;
}

export interface Patient {
  id: number;
  name: string;
  date_of_birth: string;
  phone: string | null;
  email: string | null;
  notes: string | null;
}

export type AppointmentStatus = "scheduled" | "completed" | "cancelled" | "no_show";

export interface Appointment {
  id: number;
  status: AppointmentStatus;
  starts_at: string;
  ends_at: string;
  provider: { id: number; name: string };
  patient: { id: number; name: string };
}
