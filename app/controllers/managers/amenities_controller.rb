module Managers
  class AmenitiesController < ApplicationController
    before_action :authenticate_manager!
    before_action :set_venue

    # GET /managers/turf_venues/:turf_venue_id/amenity
    def show
      amenity = @venue.amenity
      if amenity.nil?
        return render json: { error: "No amenity record found for this venue" }, status: :not_found
      end

      render json: { amenity: amenity }, status: :ok
    end

    # POST /managers/turf_venues/:turf_venue_id/amenity
    # Acts as an upsert — creates or updates the amenity record
    def create
      amenity = @venue.amenity || @venue.build_amenity

      if amenity.update(amenity_params)
        render json: { message: "Amenity saved successfully", amenity: amenity }, status: amenity.persisted? ? :ok : :created
      else
        render json: { errors: amenity.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_venue
      # Always scope to current manager's venues only
      @venue = current_user.turf_venues.find(params[:turf_venue_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Venue not found" }, status: :not_found
    end

    def amenity_params
      params.permit(
        :showers, :toilets, :floodlights, :ball_provided, :free_parking,
        :drinking_water, :bibs_vests, :spectator_seating, :canteen,
        :referee, :cctv, :wifi, :first_aid, :changing_rooms, :extra_notes
      )
    end
  end
end
