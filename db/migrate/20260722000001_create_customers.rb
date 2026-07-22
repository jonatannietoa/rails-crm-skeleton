class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :customers, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :name, null: false
      t.string :email, null: false
      # CRM metadata (Affinity.co-shaped): source, external_id, entity_type,
      # list_entry_id, fields, tags. jsonb so we can query field values later.
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :customers, :email, unique: true
  end
end
