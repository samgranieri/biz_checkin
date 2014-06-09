class CreateBusiness < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :zip
      t.string :state
      t.string :website
      t.string :phone
      t.integer :waiting_period
    end
  end
end
