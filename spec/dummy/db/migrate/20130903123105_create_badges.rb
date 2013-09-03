class CreateBadges < ActiveRecord::Migration
  def up
    create_table :badge_components do |t|
      t.references :user_badge
      t.string :key
      t.integer :progress, null: false, default: 0
      t.integer :goal
      t.boolean :complete, null: false, default: false


      t.timestamps
    end

    create_table :user_badges do |t|
      t.references :user
      t.integer :badge_id
      t.boolean :temporary, null: false , default: false
      t.integer :progress, null: false, default: 0
      t.integer :goal
      t.boolean :complete, null: false, default: false
      t.integer :level
      t.references :resource, polymorphic: true

      t.timestamps
    end

    add_index :user_badges, [:user_id, :badge_id, :resource_id, :resource_type], name: 'index_user_badges_on_user_and_badge_and_resource', unique: true
  end

  def down
    drop_table :badge_components
    drop_table :user_badges

    remove_index :user_badges, name: 'index_user_badges_on_user_and_badge_and_resource'
  end
end
