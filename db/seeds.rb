admin = User.find_or_create_by!(email: "admin@clinicflow.test") do |u|
  u.name = "Ada Admin"
  u.password = "password123"
  u.role = :admin
end

dr_ade_user = User.find_or_create_by!(email: "dr.ade@clinicflow.test") do |u|
  u.name = "Dr. Ade Bello"
  u.password = "password123"
  u.role = :provider
end
dr_ade = Provider.find_or_create_by!(user: dr_ade_user) do |p|
  p.specialty = "Family Medicine"
  p.bio = "Ten years in primary care."
end

dr_chika_user = User.find_or_create_by!(email: "dr.chika@clinicflow.test") do |u|
  u.name = "Dr. Chika Nwosu"
  u.password = "password123"
  u.role = :provider
end
dr_chika = Provider.find_or_create_by!(user: dr_chika_user) do |p|
  p.specialty = "Pediatrics"
  p.bio = "Loves working with kids and anxious parents alike."
end

patients = [
  { name: "Tola Fashola", date_of_birth: "1990-04-12", email: "tola@example.com" },
  { name: "Ifeoma Umeh", date_of_birth: "1985-11-02", email: "ifeoma@example.com" },
  { name: "Ben Okoro", date_of_birth: "2015-06-20", email: "ben.guardian@example.com" }
].map { |attrs| Patient.find_or_create_by!(email: attrs[:email]) { |p| p.assign_attributes(attrs) } }

Appointment.find_or_create_by!(provider: dr_ade, patient: patients[0], starts_at: 1.day.from_now.change(hour: 9)) do |a|
  a.ends_at = 1.day.from_now.change(hour: 9, min: 30)
end

Appointment.find_or_create_by!(provider: dr_chika, patient: patients[2], starts_at: 2.days.from_now.change(hour: 14)) do |a|
  a.ends_at = 2.days.from_now.change(hour: 14, min: 30)
end

puts "Seeded #{User.count} users, #{Provider.count} providers, #{Patient.count} patients, #{Appointment.count} appointments."
