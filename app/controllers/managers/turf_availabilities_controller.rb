module Managers
  class TurfAvailabilitiesController < ApplicationController
    before_action :authenticate_manager!
    before_action :set_venue
    before_action :set_turf

    # GET /managers/turf_venues/:turf_venue_id/turfs/:turf_id/availability
    def index
      schedule = @turf.turf_availabilities.order(:day_of_week)

      render json: { availability: format_schedule(schedule) }, status: :ok
    end

    # POST /managers/turf_venues/:turf_venue_id/turfs/:turf_id/availability
    # Upsert all 7 days at once — find_or_initialize_by then update
    def create
      availability_data = params[:availability]

      # Reject if not an array
      unless availability_data.is_a?(Array)
        return render json: { error: "availability must be an array of day objects" }, status: :bad_request
      end

      errors_per_day = []
      updated_schedule = []

      availability_data.each do |day_data|
        day = @turf.turf_availabilities.find_or_initialize_by(day_of_week: day_data[:day_of_week])

        if day.update(
          day_of_week: day_data[:day_of_week],
          is_open: day_data[:is_open],
          open_time: day_data[:open_time],
          close_time: day_data[:close_time]
        )
          updated_schedule << day
        else
          errors_per_day << { day_of_week: day_data[:day_of_week], errors: day.errors.full_messages }
        end
      end

      if errors_per_day.any?
        render json: { errors: errors_per_day }, status: :unprocessable_entity
      else
        render json: {
          message: "Availability schedule updated successfully",
          availability: format_schedule(updated_schedule)
        }, status: :ok
      end
    end

    private

    def set_venue
      @venue = current_user.turf_venues.find(params[:turf_venue_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Venue not found" }, status: :not_found
    end

    def set_turf
      @turf = @venue.turfs.find(params[:turf_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Turf not found" }, status: :not_found
    end

    def format_schedule(schedule)
      # Handle both ActiveRecord::Relation (from index) and plain Array (from create)
      sorted = schedule.respond_to?(:order) ? schedule.order(:day_of_week) : schedule.sort_by(&:day_of_week)
      sorted.map do |day|
        {
          id: day.id,
          day_of_week: day.day_of_week,
          day_name: Date::DAYNAMES[(day.day_of_week + 1) % 7],
          is_open: day.is_open,
          open_time: day.open_time,
          close_time: day.close_time
        }
      end
    end
  end
end
