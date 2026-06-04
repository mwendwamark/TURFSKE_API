module Players
  class BookingsController < ApplicationController
    before_action :authenticate_player!

    def index
      bookings = current_user.bookings
        .includes(turf: :turf_venue)
        .order(created_at: :desc)

      render json: {
        bookings: bookings.map { |b| booking_json(b) }
      }, status: :ok
    end

    def create
      raw = if params[:_json].present?
        begin
          JSON.parse(params[:_json])
        rescue JSON::ParserError
          {}
        end
      else
        params.permit(:turf_id, :slot_date, :start_time, :end_time, :duration_hours, :amount_kes).to_h
      end

      turf = Turf.find_by(id: raw["turf_id"])

      unless turf
        return render json: { error: "Turf not found." }, status: :not_found
      end

      conflict = Booking.where(
        turf_id:    turf.id,
        slot_date:  raw["slot_date"],
        start_time: raw["start_time"]
      ).where(status: ["pending", "confirmed"]).exists?

      if conflict
        return render json: { error: "This slot is already taken. Please choose another time." }, status: :unprocessable_entity
      end

      booking = current_user.bookings.build(
        turf_id:          turf.id,
        slot_date:        raw["slot_date"],
        start_time:       raw["start_time"],
        end_time:         raw["end_time"],
        duration_hours:   raw["duration_hours"],
        amount_kes:       raw["amount_kes"],
        status:           "pending",
        reference_number: "TRF-#{SecureRandom.hex(4).upcase}"
      )

      if booking.save
        render json: {
          message: "Reservation request sent!",
          booking: booking_json(booking)
        }, status: :created
      else
        render json: { errors: booking.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def booking_json(booking)
      {
        id:               booking.id,
        reference_number: booking.reference_number,
        slot_date:        booking.slot_date,
        start_time:       booking.start_time,
        end_time:         booking.end_time,
        duration_hours:   booking.duration_hours,
        amount_kes:       booking.amount_kes,
        status:           booking.status,
        created_at:       booking.created_at,
        turf: {
          id:             booking.turf.id,
          name:           booking.turf.name,
          pitch_format:   booking.turf.pitch_format,
          price_per_hour: booking.turf.price_per_hour,
        },
        venue: {
          id:              booking.turf.turf_venue.id,
          name:            booking.turf.turf_venue.name,
          county:          booking.turf.turf_venue.county,
          contact_phone:   booking.turf.turf_venue.contact_phone,
          whatsapp_number: booking.turf.turf_venue.whatsapp_number,
        }
      }
    end
  end
end