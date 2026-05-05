module Managers
  class TurfVenuesController < ApplicationController
    before_action :authenticate_manager!
    before_action :set_venue, only: [:show, :update, :destroy, :upload_images, :delete_image]

    # GET /managers/turf_venues
    def index
      venues = current_user.turf_venues
        .includes(:amenity, :turfs, images_attachments: :blob)
        .order(created_at: :desc)

      render json: { venues: venues.map { |v| venue_index_json(v) } }, status: :ok
    end

    # GET /managers/turf_venues/:id
    def show
      render json: { venue: venue_detail_json(@venue) }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Venue not found" }, status: :not_found
    end

    # POST /managers/turf_venues
    def create
      @venue = current_user.turf_venues.build(venue_params)
      @venue.status = "active" if @venue.status.blank?

      if @venue.save
        render json: { message: "Venue created successfully", venue: venue_detail_json(@venue) }, status: :created
      else
        render json: { errors: @venue.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # POST /managers/turf_venues/complete_create
    # Creates venue, amenity, turf, availability, and uploads images in a single transaction
    def complete_create
      ActiveRecord::Base.transaction do
        # 1. Create venue
        @venue = current_user.turf_venues.build(complete_create_venue_params)
        @venue.status = "active" if @venue.status.blank?
        @venue.save!

        # 2. Create amenity if provided
        amenity_data = params[:amenity]
        if amenity_data.present?
          amenity_payload = amenity_data.permit(
            :showers, :toilets, :floodlights, :ball_provided, :free_parking,
            :drinking_water, :bibs_vests, :spectator_seating, :canteen, :referee,
            :cctv, :wifi, :first_aid, :changing_rooms, :extra_notes
          )
          @venue.create_amenity!(amenity_payload)
        end

        # 3. Create turf if provided
        turf_data = params[:turf]
        if turf_data.present?
          turf_payload = turf_data.permit(
            :name, :surface_type, :pitch_format, :pitch_length_m, :pitch_width_m,
            :price_per_hour, :peak_price, :peak_from, :peak_to, :min_booking_minutes,
            :slot_duration_minutes, :buffer_minutes, :auto_approve, :status
          )
          @turf = @venue.turfs.create!(turf_payload)

          # 4. Create availability if provided
          availability_data = params[:availability]
          if availability_data.present?
            availability_data.values.each do |day_data|
              @turf.turf_availabilities.create!(
                day_data.permit(:day_of_week, :is_open, :open_time, :close_time)
              )
            end
          end
        end
      end

      # 5. Upload images if provided (outside transaction — images can be added later)
      if params[:images].present?
        files = Array(params[:images])
        files.each do |file|
          @venue.images.attach(file)
        end
      end

      render json: { message: "Turf venue created successfully", venue: venue_detail_json(@venue) }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      # Rollback happens automatically due to transaction
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue => e
      render json: { errors: [e.message] }, status: :unprocessable_entity
    end

    # PATCH/PUT /managers/turf_venues/:id
    def update
      if @venue.update(venue_params)
        render json: { message: "Venue updated successfully", venue: venue_detail_json(@venue) }, status: :ok
      else
        render json: { errors: @venue.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /managers/turf_venues/:id
    def destroy
      @venue.destroy
      render json: { message: "Venue deleted successfully" }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Venue not found" }, status: :not_found
    end

    # POST /managers/turf_venues/:id/upload_images
    def upload_images
      # Reject if no files provided
      if params[:images].blank?
        return render json: { error: "No images provided" }, status: :bad_request
      end

      # Reject if venue already has 6 or more images
      if @venue.images.count >= 6
        return render json: { error: "Maximum 6 images allowed per venue" }, status: :unprocessable_entity
      end

      files = Array(params[:images])

      # Check if adding these files would exceed the limit
      if @venue.images.count + files.count > 6
        return render json: { error: "Maximum 6 images allowed per venue" }, status: :unprocessable_entity
      end

      errors = []
      files.each do |file|
        @venue.images.attach(file)
      end

      # Check for attachment errors
      if @venue.errors.any?
        errors = @venue.errors.full_messages
        return render json: { errors: errors }, status: :unprocessable_entity
      end

      render json: {
        message: "Images uploaded successfully",
        venue: venue_detail_json(@venue)
      }, status: :ok
    end

    # DELETE /managers/turf_venues/:id/delete_image/:image_id
    def delete_image
      image = @venue.images.find(params[:image_id])
      image.purge
      render json: {
        message: "Image deleted successfully",
        venue: venue_detail_json(@venue)
      }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Image not found" }, status: :not_found
    end

    private

    def set_venue
      # Always scope to current manager's venues only
      @venue = current_user.turf_venues.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Venue not found" }, status: :not_found
    end

    def venue_params
      params.permit(
        :name, :description, :full_address, :county, :landmark,
        :latitude, :longitude, :contact_phone, :whatsapp_number,
        :contact_email, :status
      )
    end

    def complete_create_venue_params
      params.require(:venue).permit(
        :name, :description, :full_address, :county, :landmark,
        :latitude, :longitude, :contact_phone, :whatsapp_number,
        :contact_email, :status
      )
    end

    # Compact JSON for index — includes amenity summary, turf list, and image URLs
    def venue_index_json(venue)
      {
        id: venue.id,
        name: venue.name,
        description: venue.description,
        full_address: venue.full_address,
        county: venue.county,
        landmark: venue.landmark,
        latitude: venue.latitude,
        longitude: venue.longitude,
        contact_phone: venue.contact_phone,
        whatsapp_number: venue.whatsapp_number,
        contact_email: venue.contact_email,
        status: venue.status,
        created_at: venue.created_at,
        updated_at: venue.updated_at,
        amenity_summary: amenity_summary_json(venue.amenity),
        turfs: venue.turfs.map { |t| turf_summary_json(t) },
        image_urls: venue.images.map { |img| rails_blob_url(img, only_path: true) }
      }
    end

    # Full JSON for show — includes amenity, all turfs with availabilities, and image URLs
    def venue_detail_json(venue)
      {
        id: venue.id,
        name: venue.name,
        description: venue.description,
        full_address: venue.full_address,
        county: venue.county,
        landmark: venue.landmark,
        latitude: venue.latitude,
        longitude: venue.longitude,
        contact_phone: venue.contact_phone,
        whatsapp_number: venue.whatsapp_number,
        contact_email: venue.contact_email,
        status: venue.status,
        created_at: venue.created_at,
        updated_at: venue.updated_at,
        amenity: venue.amenity,
        turfs: venue.turfs.includes(:turf_availabilities).order(:name).map { |t| turf_with_availability_json(t) },
        image_urls: venue.images.map { |img| rails_blob_url(img, only_path: true) }
      }
    end

    def amenity_summary_json(amenity)
      return nil if amenity.nil?
      {
        id: amenity.id,
        showers: amenity.showers,
        toilets: amenity.toilets,
        floodlights: amenity.floodlights,
        free_parking: amenity.free_parking,
        canteen: amenity.canteen
      }
    end

    def turf_summary_json(turf)
      {
        id: turf.id,
        name: turf.name,
        pitch_format: turf.pitch_format,
        price_per_hour: turf.price_per_hour,
        status: turf.status
      }
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
