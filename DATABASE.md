TURFSKE — DATABASE TABLES
TABLE 1: USERS
ruby
class CreateUsers < ActiveRecord::Migration[7.1]
def change
create_table :users, id: :uuid do |t|
t.string :full_name, null: false
t.string :phone, null: false
t.string :password_digest, null: false
t.string :role, null: false, default: 'player'
t.string :email
t.string :business_name
t.string :county
t.text :fcm_token
t.string :status, null: false, default: 'active'
t.timestamps
end
add_index :users, :phone, unique: true
add_index :users, :email, unique: true, where: "email IS NOT NULL"
add_index :users, :role
end
end
What each column does:
full_name — the person's full name, collected during sign up, displayed on the dashboard and
booking confirmations.
phone — the login identifier. We use phone instead of email because most Kenyan users are
more consistent with their phone numbers. Must be unique across all users.
password_digest — Rails does not store plain text passwords. When a user creates a
password, Rails uses a gem called bcrypt to convert it into a scrambled unreadable string
called a hash and stores that instead. When they log in, bcrypt checks if their entered password
matches that hash. You enable this by adding has_secure_password to the User model.
role — this single column determines which version of the app the user sees. Value is either
player or manager. Players see the discovery and booking flow. Managers see the dashboard
and turf management screens.

email — optional at sign up. Some users may not want to provide it.
business_name — only relevant for managers. Stores their trading name e.g. "Ballmania
Kenya."
county — only relevant for managers. Helps with future region-based filtering.
fcm_token — Firebase Cloud Messaging token. This is a unique string that identifies the
specific phone of this user. When you want to send a push notification to someone, you send it
to this token. It gets updated every time the user opens the app because the device can issue a
new token after reinstalls or OS updates.
status — either active or suspended. An active account works normally. A suspended
account cannot log in. Useful for admin moderation later.
TABLE 2: TURF_VENUES
ruby
class CreateTurfVenues < ActiveRecord::Migration[7.1]
def change
create_table :turf_venues, id: :uuid do |t|
t.references :user, null: false, foreign_key: true, type: :uuid
t.string :name, null: false
t.text :description
t.text :full_address, null: false
t.string :county, null: false
t.string :landmark
t.decimal :latitude, precision: 10 , scale: 7 , null: false
t.decimal :longitude, precision: 10 , scale: 7 , null: false
t.string :contact_phone, null: false
t.string :whatsapp_number
t.string :contact_email
t.string :paystack_reference
t.string :status, null: false, default: 'draft'
t.timestamps
end
add_index :turf_venues, :user_id
add_index :turf_venues, :status
add_index :turf_venues, [:latitude, :longitude]
end
end

What each column does:
user_id — links this venue to the manager who owns it. A manager can own multiple venues
at different locations.
name — the public name of the facility e.g. "Ballmania Westlands" or "Kasarani Sports
Complex."
description — a short paragraph the manager writes about the facility. Shown to players on
the venue detail screen.
full_address — the street and estate address e.g. "Ring Road, Westlands." Used for
directions.
county — used for region-based filtering e.g. a player can filter turfs in Nairobi only.
landmark — an optional nearby reference point to help players find the place e.g. "Opposite
Westgate Mall." Very useful in Kenya where addresses can be vague.
latitude and longitude — the exact GPS coordinates of the venue entrance. Stored as
decimal numbers with 7 decimal places for precision. These are what power the map pin and
the distance calculation from the player's current location. The manager sets this by dragging a
pin on the map in the Add Turf form.
contact_phone — the phone number shown to players on the detail screen so they can call
the facility.
whatsapp_number — optional. If provided, players can tap a WhatsApp button to message the
facility directly.
contact_email — optional contact email for formal enquiries.
paystack_reference — when a manager submits a new venue and needs to pay the listing
fee, the Rails backend generates a unique reference string like TKE-PAY-abc123 and stores it
here. This reference is sent to Paystack along with the payment request. When Paystack
processes the payment and sends a callback to your server, it includes this same reference so
your backend knows exactly which venue to activate. Think of it as a tracking number that links
the payment to the venue.
status — the lifecycle of the venue listing. draft means the venue was created but the listing
fee has not been paid yet, so players cannot see it. active means the payment was confirmed
and the venue is live on the discovery screen. inactive means the manager has temporarily
hidden it.

TABLE 3: AMENITIES
ruby
class CreateAmenities < ActiveRecord::Migration[7.1]
def change
create_table :amenities, id: :uuid do |t|
t.references :turf_venue, null: false, foreign_key: true, type: :uuid
t.boolean :showers, null: false, default: false
t.boolean :toilets, null: false, default: false
t.boolean :floodlights, null: false, default: false
t.boolean :ball_provided, null: false, default: false
t.boolean :free_parking, null: false, default: false
t.boolean :drinking_water, null: false, default: false
t.boolean :bibs_vests, null: false, default: false
t.boolean :spectator_seating,null: false, default: false
t.canteen :canteen, null: false, default: false
t.boolean :referee, null: false, default: false
t.boolean :cctv, null: false, default: false
t.boolean :wifi, null: false, default: false
t.boolean :first_aid, null: false, default: false
t.boolean :changing_rooms, null: false, default: false
t.text :extra_notes
t.timestamps
end
add_index :amenities, :turf_venue_id, unique: true
end
end
What each column does:
Each boolean column represents one amenity. true means the facility has it, false means it
does not. All default to false so the manager only needs to toggle on what they actually have.
On the Add Turf form in Figma you already have these as checkboxes — each checkbox maps
directly to one of these boolean columns.
turf_venue_id — links amenities to the venue they belong to. The unique index ensures
each venue has exactly one amenities record.
extra_notes — a free text field where the manager can type any amenity that is not in the
predefined list e.g. "We have a juice bar and a physio on weekends." This is the provision you
asked for to handle things not covered by the checkboxes.

Why booleans and not an array? Booleans are faster to query. When a player filters for turfs
with floodlights and free parking, the SQL query is simply WHERE floodlights = true AND
free_parking = true. With an array you need more complex queries. Booleans also make
it immediately obvious what a venue has without parsing any data structure.
TABLE 4: TURFS
ruby
class CreateTurfs < ActiveRecord::Migration[7.1]
def change
create_table :turfs, id: :uuid do |t|
t.references :turf_venue, null: false, foreign_key: true, type: :uuid
t.string :name, null: false
t.string :surface_type, null: false
t.string :pitch_format, null: false
t.decimal :pitch_length_m, precision: 6 , scale: 2
t.decimal :pitch_width_m, precision: 6 , scale: 2
t.integer :price_per_hour, null: false
t.integer :peak_price
t.time :peak_from
t.time :peak_to
t.integer :min_booking_minutes, null: false, default: 60
t.integer :slot_duration_minutes, null: false, default: 60
t.integer :buffer_minutes, null: false, default: 0
t.boolean :auto_approve, null: false, default: false
t.string :status, null: false, default: 'active'
t.timestamps
end
add_index :turfs, :turf_venue_id
add_index :turfs, :status
end
end
What each column does:
turf_venue_id — links this pitch to its parent venue. One venue can have many turfs under
it.
name — the name of the individual pitch e.g. "Pitch A", "Main Pitch", "5-a-side Court 1." Useful
when a venue has multiple pitches so players and managers can tell them apart.

surface_type — what the playing surface is made of. Values: artificial, natural, or
both. Shown on the turf card and detail screen. Players often have a strong preference
between artificial and natural grass.
pitch_format — what game size the pitch supports. Values: 5-a-side, 7-a-side, or
11-a-side. This is one of the most commonly used filters by players.
pitch_length_m and pitch_width_m — optional dimensions of the pitch in metres. Some
teams want to know the exact size before booking especially for training sessions.
price_per_hour — the standard hourly rate in KES. This is what is shown on the discovery
card and used to calculate the booking amount.
peak_price, peak_from, peak_to — optional peak hour pricing. A manager can charge
more during busy hours for example KES 1,500 per hour from 17:00 to 21:00 on weekdays
instead of the standard KES 800. If peak_price is null the standard price applies at all times.
min_booking_minutes — the shortest session a player can book. If this is 60, a player
cannot book for just 30 minutes. They must book at least one full hour. This prevents very short
bookings that are not worth the manager's time.
slot_duration_minutes — this controls how the time grid is divided on the booking screen.
If it is 60, the player sees slots at 06:00, 07:00, 08:00 and so on. If it is 90, they see 06:00,
07:30, 09:00. The booking screen generates these slots dynamically by starting from the turf's
open_time and adding this number of minutes repeatedly until close_time is reached.
buffer_minutes — the gap between consecutive bookings. If this is 15, after a booking ends
at 17:00 the next available slot does not start until 17:15. This gives the facility time to clear the
pitch, check the nets, and prepare for the next group.
auto_approve — when false, every booking goes to the manager's dashboard as pending
and they manually approve or decline it. When true, the backend automatically marks every
new booking as confirmed the moment it is submitted, with no manager action needed. On
the Add Turf form this is simply a toggle switch.
status — active means the pitch is visible and bookable. inactive means the manager
has hidden it, for example while a pitch is being resurfaced. Inactive turfs never appear in player
search results.
TABLE 5: TURF_AVAILABILITIES
ruby

class CreateTurfAvailabilities < ActiveRecord::Migration[7.1]
def change
create_table :turf_availabilities, id: :uuid do |t|
t.references :turf, null: false, foreign_key: true, type: :uuid
t.integer :day_of_week, null: false
t.boolean :is_open, null: false, default: true
t.time :open_time, null: false
t.time :close_time, null: false
t.timestamps
end
add_index :turf_availabilities, [:turf_id, :day_of_week], unique: true
end
end
What each column does:
turf_id — links this schedule row to a specific pitch.
day_of_week — an integer representing the day. 0 is Monday, 1 is Tuesday, 2 is Wednesday,
3 is Thursday, 4 is Friday, 5 is Saturday, 6 is Sunday. When a manager fills in the availability
screen in Figma where they toggle each day and set times, your backend creates one row per
day for that turf. So a turf open Monday to Saturday has 7 rows — six with is_open: true
and Sunday with is_open: false.
is_open — whether the turf operates on this day at all. If false, the open_time and close_time
are irrelevant and players cannot book on that day.
open_time and close_time — the operating hours for that day. e.g. 06:00 to 23:00. The slot
grid the player sees on the booking screen is generated from these two values combined with
the turf's slot_duration_minutes.
The unique index on [turf_id, day_of_week] ensures you cannot accidentally create two
schedule rows for the same day on the same turf.
TABLE 6: BOOKINGS
ruby
class CreateBookings < ActiveRecord::Migration[7.1]
def change
create_table :bookings, id: :uuid do |t|

t.references :turf, null: false, foreign_key: true, type: :uuid
t.references :player, null: false,
foreign_key: { to_table: :users },
type: :uuid
t.string :reference_number, null: false
t.date :slot_date, null: false
t.time :start_time, null: false
t.time :end_time, null: false
t.decimal :duration_hours, precision: 4 , scale: 2 , null: false
t.integer :amount_kes, null: false
t.string :status, null: false, default: 'pending'
t.text :cancel_reason
t.string :cancelled_by
t.timestamps
end
add_index :bookings, :reference_number, unique: true
add_index :bookings, :player_id
add_index :bookings, [:turf_id, :slot_date]
add_index :bookings, :status
add_index :bookings,
[:turf_id, :slot_date, :start_time],
unique: true,
where: "status IN ('pending', 'confirmed')",
name: 'idx_bookings_no_double_booking'
end
end
What each column does:
turf_id — which specific pitch was booked.
player_id — which user made the booking. The foreign key points to the users table with
to_table: :users because the column is called player_id not user_id.
reference_number — yes, you understood this correctly. This is the player's ticket. When the
booking is confirmed, the player presents this number at the gate and the manager checks it
against their bookings list. Format it as something human-readable like TKE-20260501-0042.
The unique index ensures no two bookings ever get the same reference.
slot_date — the calendar date of the session e.g. 2026-05-01. Stored separately from the
time so you can query all bookings for a specific day efficiently.

start_time and end_time — when the session starts and ends e.g. 16:00 and 17:00.
duration_hours — yes, this is the total length of the session the player booked. 16:00 to
17:00 is 1.0 hour. 16:00 to 18:00 is 2.0 hours. Stored explicitly so you do not have to recalculate
it every time you need to display it or compute the amount.
amount_kes — the total cost of this booking in Kenyan Shillings. Calculated at the time of
booking as duration_hours multiplied by price_per_hour. Stored so the price is locked in even if
the manager later changes the turf's price.
status — three values for your MVP. pending means the player submitted the booking and is
waiting for the manager to respond. confirmed means the manager approved it or
auto_approve fired. declined means the manager rejected it.
cancel_reason — a text field the manager fills in when declining a booking. This is shown to
the player so they understand why they were declined e.g. "Pitch closed for maintenance that
day." Without this, the player gets a decline notification with no context which is a poor
experience.
cancelled_by — stores either player or manager so you know who initiated the
cancellation. Useful for records and for displaying the right message to each party.
The most important index in the whole project is idx_bookings_no_double_booking. It
is a partial unique index on [turf_id, slot_date, start_time] that only applies to rows
where status is pending or confirmed. This means the database itself will physically reject
any attempt to create a second active booking for the same pitch at the same time on the same
date. This is your first come first served enforcement. It happens at the database level so it
works even if two players tap "Request Booking" at the exact same millisecond.
TABLE 7: PAYMENTS
ruby
class CreatePayments < ActiveRecord::Migration[7.1]
def change
create_table :payments, id: :uuid do |t|
t.references :turf_venue, null: false, foreign_key: true, type: :uuid
t.references :user, null: false, foreign_key: true, type: :uuid
t.string :payment_type, null: false
t.integer :amount_kobo, null: false
t.string :currency, null: false, default: 'KES'
t.string :paystack_reference, null: false
t.string :paystack_transaction_id

t.string :channel
t.string :status, null: false, default: 'pending'
t.jsonb :paystack_metadata
t.string :paid_at
t.timestamps
end
add_index :payments, :paystack_reference, unique: true
add_index :payments, :user_id
add_index :payments, :turf_venue_id
add_index :payments, :status
end
end
What each column does:
turf_venue_id — which venue this payment is for.
user_id — which manager made the payment.
payment_type — what the payment is for. For now the only value is listing_fee which is
what the manager pays to activate their venue. In the future you can add
booking_commission when you take a cut from each booking.
amount_kobo — Paystack stores amounts in the smallest unit of the currency. For KES this is
cents so KES 500 is stored as 50000. This avoids floating point precision problems with decimal
money values.
currency — defaults to KES. Stored so the payments table can support other currencies in the
future.
paystack_reference — the unique tracking string your backend generated and sent to
Paystack. When Paystack calls your webhook after the payment, it sends this reference back
and your backend uses it to find this payment record and update its status.
paystack_transaction_id — Paystack's own internal ID for the transaction. Useful for
looking up transactions on the Paystack dashboard.
channel — how the customer paid. Paystack will tell you this in the webhook e.g. card,
mobile_money, bank, ussd.
status — pending when the payment was initiated, success when Paystack confirms it,
failed when the payment was rejected or timed out.

paystack_metadata — the complete raw JSON payload that Paystack sends to your
webhook stored verbatim in the database. You keep this for auditing and debugging. If
something goes wrong with a payment you have the full original data to investigate.
paid_at — the timestamp from Paystack of when the payment was completed.
TABLE 8: REVIEWS
ruby
class CreateReviews < ActiveRecord::Migration[7.1]
def change
create_table :reviews, id: :uuid do |t|
t.references :turf, null: false, foreign_key: true, type: :uuid
t.references :booking, null: false, foreign_key: true, type: :uuid
t.references :player, null: false,
foreign_key: { to_table: :users },
type: :uuid
t.integer :rating, null: false
t.text :comment
t.timestamps
end
add_index :reviews, [:player_id, :booking_id], unique: true
add_index :reviews, :turf_id
end
end
What each column does:
turf_id — which pitch is being reviewed. Used to calculate the average rating displayed on
that turf's detail screen.
booking_id — this is the integrity guard. Before your backend accepts a review it checks
three things: does this booking exist, does it belong to the player submitting the review, and has
the slot date already passed. This means a player cannot review a turf they never played at and
cannot review a session that has not happened yet. Without booking_id any user could review
any turf without ever having been there, making your reviews meaningless.
player_id — who wrote the review. Used to display the reviewer's name alongside their
comment.

rating — a number from 1 to 5. Enforce this in the model with a validation: validates
:rating, inclusion: { in: 1..5 }.
comment — the optional written review text. A player might just leave a star rating without a
written comment and that is fine.
The unique index on [player_id, booking_id] ensures a player can only leave one
review per booking. They cannot submit multiple reviews for the same session.

RAILS COMMANDS — run these in order
bash
rails generate model User full_name:string phone:string
password_digest:string role:string email:string business_name:string
county:string fcm_token:text status:string
rails generate model TurfVenue user:references name:string description:text
full_address:text county:string landmark:string latitude:decimal
longitude:decimal contact_phone:string whatsapp_number:string
contact_email:string paystack_reference:string status:string
rails generate model Amenity turf_venue:references showers:boolean
toilets:boolean floodlights:boolean ball_provided:boolean
free_parking:boolean drinking_water:boolean bibs_vests:boolean
spectator_seating:boolean canteen:boolean referee:boolean cctv:boolean
wifi:boolean first_aid:boolean changing_rooms:boolean extra_notes:text
rails generate model Turf turf_venue:references name:string
surface_type:string pitch_format:string pitch_length_m:decimal
pitch_width_m:decimal price_per_hour:integer peak_price:integer
peak_from:time peak_to:time min_booking_minutes:integer
slot_duration_minutes:integer buffer_minutes:integer auto_approve:boolean
status:string
rails generate model TurfAvailability turf:references day_of_week:integer
is_open:boolean open_time:time close_time:time
rails generate model Booking turf:references reference_number:string
slot_date:date start_time:time end_time:time duration_hours:decimal
amount_kes:integer status:string cancel_reason:text cancelled_by:string
rails generate model Payment turf_venue:references user:references
payment_type:string amount_kobo:integer currency:string
paystack_reference:string paystack_transaction_id:string channel:string
status:string paystack_metadata:jsonb paid_at:string
rails generate model Review turf:references booking:references
rating:integer comment:text
Then run:
bash
rails db:migrate