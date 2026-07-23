module Customers
  # CRM metadata attached to a customer, modelled after Affinity.co.
  #
  # In Affinity an entity (a person or an organization) has an id, may live on a
  # list as a "list entry", and carries "field values" — the custom fields
  # configured for that list/entity. We capture that shape as an immutable value
  # object so the customer aggregate can own its CRM data without depending on
  # any CRM SDK.
  #
  #   source        which CRM this came from (e.g. "affinity")
  #   external_id   the entity id inside the CRM
  #   entity_type   "person" | "organization" | "opportunity"
  #   list_entry_id id of the Affinity list entry (optional)
  #   fields        custom field name => value (Affinity "field values")
  #   tags          free-form labels
  class CRMMetadata
    ENTITY_TYPES = %w[person organization opportunity].freeze

    attr_reader :source, :external_id, :entity_type, :list_entry_id, :fields, :tags

    def self.create(source:, external_id:, entity_type:, list_entry_id: nil, fields: {}, tags: [])
      source = source.to_s.strip.downcase
      raise Shared::InvalidInputError, "The CRM source is required." if source.empty?

      external_id = external_id.to_s.strip
      raise Shared::InvalidInputError, "The CRM external id is required." if external_id.empty?

      entity_type = entity_type.to_s.strip.downcase
      unless ENTITY_TYPES.include?(entity_type)
        raise Shared::InvalidInputError,
          "\"#{entity_type}\" is not a valid CRM entity type (#{ENTITY_TYPES.join(', ')})."
      end

      new(
        source: source,
        external_id: external_id,
        entity_type: entity_type,
        list_entry_id: list_entry_id&.to_s,
        fields: normalize_fields(fields),
        tags: Array(tags).map { |t| t.to_s.strip }.reject(&:empty?).uniq,
      )
    end

    # Rebuilds the value object from the persisted JSON (string keys).
    def self.rehydrate(raw)
      raw = (raw || {}).transform_keys(&:to_s)
      new(
        source: raw["source"],
        external_id: raw["external_id"],
        entity_type: raw["entity_type"],
        list_entry_id: raw["list_entry_id"],
        fields: normalize_fields(raw["fields"] || {}),
        tags: Array(raw["tags"]),
      )
    end

    def self.normalize_fields(fields)
      (fields || {}).to_h.transform_keys(&:to_s)
    end
    private_class_method :normalize_fields

    def initialize(source:, external_id:, entity_type:, list_entry_id:, fields:, tags:)
      @source = source
      @external_id = external_id
      @entity_type = entity_type
      @list_entry_id = list_entry_id
      @fields = fields.freeze
      @tags = tags.freeze
      freeze
    end

    # Canonical hash for persistence (jsonb) and read models — string keys.
    def to_h
      {
        "source" => source,
        "external_id" => external_id,
        "entity_type" => entity_type,
        "list_entry_id" => list_entry_id,
        "fields" => fields,
        "tags" => tags,
      }
    end

    def ==(other)
      other.is_a?(CRMMetadata) && other.to_h == to_h
    end
    alias eql? ==

    def hash
      to_h.hash
    end
  end
end
