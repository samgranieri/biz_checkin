class CreateCheckin < ActiveRecord::Migration
  def change
    create_table :checkins do |t|
      t.references :user, index: true
      t.references :business, index: true
      t.timestamps
    end
  end
end
