class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.datetime :pubdate
      t.string :title
      t.text :body
      t.string :image_url
      t.timestamps
    end
  end
end
