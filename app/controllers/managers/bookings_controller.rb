module Managers
  class BookingsController < ApplicationController
    before_action :authenticate_manager!

    def index
      venues = current_user.turf_venues.includes(turfs: :bookings)
      bookings = venues.flat_map do |venue|
        venue.turfs.flat_map do |turf|
          turf.bookings.includes(:player).order(created_at: :desc)
        end
      end

      pending_bookings   = bookings.select { |b| b.status == "pending" }
      confirmed_bookings = bookings.select { |b| b.status == "confirmed" }
      all_bookings       = pending_bookings + confirmed_bookings

      render json: {
        pending_count: pending_bookings.count,
        bookings: all_bookings.map { |b| manager_booking_json(b) }
      }, status: :ok
    end

    def confirm
      booking = find_booking
      return unless booking

      booking.update!(status: "confirmed")
      render json: { message: "Booking confirmed.", booking: manager_booking_json(booking) }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    def cancel
      booking = find_booking
      return unless booking

      booking.update!(status: "cancelled", cancel_reason: params[:reason], cancelled_by: "manager")
      render json: { message: "Booking cancelled.", booking: manager_booking_json(booking) }, status: :ok
    end

    private

    def find_booking
      venue_ids = current_user.turf_venues.pluck(:id)
      turf_ids  = Turf.where(turf_venue_id: venue_ids).pluck(:id)
      booking   = Booking.includes(:player, turf: :turf_venue).find_by(id: params[:id], turf_id: turf_ids)
      render json: { error: "Booking not found" }, status: :not_found unless booking
      booking
    end

    def manager_booking_json(booking)
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
        player: {
          id:           booking.player.id,
          first_name:   booking.player.first_name,
          last_name:    booking.player.last_name,
          phone_number: booking.player.phone_number,
          email:        booking.player.email,
        },
        turf: {
          id:           booking.turf.id,
          name:         booking.turf.name,
          pitch_format: booking.turf.pitch_format,
          price_per_hour: booking.turf.price_per_hour,
        },
        venue: {
          id:     booking.turf.turf_venue.id,
          name:   booking.turf.turf_venue.name,
          county: booking.turf.turf_venue.county,
        }
      }
    end
  end
end
