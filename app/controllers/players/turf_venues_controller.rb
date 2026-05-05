module Players
  class TurfVenuesController < ApplicationController
    before_action :authenticate_player!

    # GET /players/turf_venues
    # Returns compact card-friendly list of active venues
    def index
      venues = TurfVenue.where(status: "active")

      # Filter by county if provided
      if params[:county].present?
        venues = venues.where(county: params[:county])
      end

      # Filter by pitch_format — venues that have at least one active turf with that format
      if params[:pitch_format].present?
        venues = venues.joins(:turfs)
          .where(turfs: { status: "active", pitch_format: params[:pitch_format] })
          .distinct
      end

      venues = venues.includes(:amenity, turfs: :turf_availabilities, images_attachments: :blob)

      # Distance sorting via Haversine formula when coordinates are provided
      if params[:lat].present? && params[:lng].present?
        lat = params[:lat].to_f
        lng = params[:lng].to_f

        # Haversine formula in raw SQL for distance in kilometers
        haversine_sql = <<-SQL.squish
          6371.0 * acos(
            least(1, greatest(-1,
              sin(radians(#{lat})) * sin(radians(CAST(turf_venues.latitude AS float))) +
              cos(radians(#{lat})) * cos(radians(CAST(turf_venues.latitude AS float))) *
              cos(radians(CAST(turf_venues.longitude AS float)) - radians(#{lng}))
            ))
          )
        SQL

        venues = venues.select("turfs.*, #{haversine_sql} AS distance_km").order("distance_km ASC")
      else
        venues = venues.order(created_at: :desc)
      end

      render json: { venues: venues.map { |v| venue_index_json(v) } }, status: :ok
    end

    # GET /players/turf_venues/:id
    # Returns full venue detail with all active turfs and their availabilities
    def show
      venue = TurfVenue.where(status: "active")
        .includes(:amenity, turfs: :turf_availabilities, images_attachments: :blob)
        .find(params[:id])

      render json: { venue: venue_detail_json(venue) }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Venue not found" }, status: :not_found
    end

    private

    def venue_index_json(venue)
      active_turfs = venue.turfs.where(status: "active")
      prices = active_turfs.pluck(:price_per_hour).compact
      formats = active_turfs.pluck(:pitch_format).compact.uniq

      result = {
        id: venue.id,
        name: venue.name,
        county: venue.county,
        full_address: venue.full_address,
        landmark: venue.landmark,
        latitude: venue.latitude,
        longitude: venue.longitude,
        contact_phone: venue.contact_phone,
        whatsapp_number: venue.whatsapp_number,
        cover_image_url: venue.images.attached? ? rails_blob_url(venue.images.first, only_path: true) : nil,
        active_turfs_count: active_turfs.count,
        price_range: {
          min: prices.min,
          max: prices.max
        },
        pitch_formats: formats
      }

      # Add distance_km if it was calculated via Haversine
      if venue.respond_to?(:distance_km) && venue.distance_km.present?
        result[:distance_km] = venue.distance_km.round(1)
      end

      result
    end

    def venue_detail_json(venue)
      active_turfs = venue.turfs.where(status: "active").includes(:turf_availabilities)

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
        image_urls: venue.images.map { |img| rails_blob_url(img, only_path: true) },
        amenity: venue.amenity,
        turfs: active_turfs.order(:name).map { |t| turf_detail_json(t) }
      }
    end

    def turf_detail_json(turf)
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
