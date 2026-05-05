module Managers
  class TurfsController < ApplicationController
    before_action :authenticate_manager!
    before_action :set_venue
    before_action :set_turf, only: [:show, :update, :destroy]

    # GET /managers/turf_venues/:turf_venue_id/turfs
    def index
      turfs = @venue.turfs.includes(:turf_availabilities).order(:name)

      render json: { turfs: turfs.map { |t| turf_with_availability_json(t) } }, status: :ok
    end

    # GET /managers/turf_venues/:turf_venue_id/turfs/:id
    def show
      render json: { turf: turf_with_availability_json(@turf) }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Turf not found" }, status: :not_found
    end

    # POST /managers/turf_venues/:turf_venue_id/turfs
    def create
      @turf = @venue.turfs.build(turf_params)

      if @turf.save
        render json: { message: "Turf created successfully", turf: turf_with_availability_json(@turf) }, status: :created
      else
        render json: { errors: @turf.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /managers/turf_venues/:turf_venue_id/turfs/:id
    def update
      if @turf.update(turf_params)
        render json: { message: "Turf updated successfully", turf: turf_with_availability_json(@turf) }, status: :ok
      else
        render json: { errors: @turf.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /managers/turf_venues/:turf_venue_id/turfs/:id
    def destroy
      @turf.destroy
      render json: { message: "Turf deleted successfully" }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Turf not found" }, status: :not_found
    end

    private

    def set_venue
      # Always scope to current manager's venues only
      @venue = current_user.turf_venues.find(params[:turf_venue_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Venue not found" }, status: :not_found
    end

    def set_turf
      # Always scope to the parent venue's turfs
      @turf = @venue.turfs.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Turf not found" }, status: :not_found
    end

    def turf_params
      params.permit(
        :name, :surface_type, :pitch_format, :pitch_length_m, :pitch_width_m,
        :price_per_hour, :peak_price, :peak_from, :peak_to,
        :min_booking_minutes, :slot_duration_minutes, :buffer_minutes,
        :auto_approve, :status
      )
    end

    def turf_with_availability_json(turf)
      {
        id: turf.id,
        name: turf.name,
        surface_type: turf.surface_type,
        pitch_format: turf.pitch_format,
        pitch_length_m: turf.pitch_length_m,
        pitch_width_m: turf.pitch_width_m,
        price_per_hour: turf.price_per_hour,
        peak_price: turf.peak_price,
        peak_from: turf.peak_from,
        peak_to: turf.peak_to,
        min_booking_minutes: turf.min_booking_minutes,
        slot_duration_minutes: turf.slot_duration_minutes,
        buffer_minutes: turf.buffer_minutes,
        auto_approve: turf.auto_approve,
        status: turf.status,
        created_at: turf.created_at,
        updated_at: turf.updated_at,
        availabilities: turf.turf_availabilities.order(:day_of_week).map do |day|
          {
            id: day.id,
            day_of_week: day.day_of_week,
            day_name: Date::DAYNAMES[(day.day_of_week + 1) % 7],
            is_open: day.is_open,
            open_time: day.open_time,
            close_time: day.close_time
          }
        end
      }
    end
  end
end
