unless File.exist?('Gemfile')
  File.write('Gemfile', <<-GEMFILE)
    source 'https://rubygems.org'
    ruby '2.2.0'
    gem 'rails', '4.2.0'
    gem 'mysql2'
  GEMFILE

  system 'bundle'
end

require 'bundler'
Bundler.setup(:default)

require 'active_record'
require 'minitest/autorun'
require 'logger'

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'mysql2', database: 'test', username: 'root', password: 'root')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :blog_posts, force: true  do |t|
    t.text :content
    # t.boolean :preview
  end

  # change_table :posts, force: true do |t|
  #   t.change :preview, :boolean, :null => false, :default => false
  # end
  
  add_column :blog_posts, :preview, :text, :null => false

  change_column :blog_posts, :preview, :boolean, :null => false, :default => false

  create_table :comments, force: true  do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < Minitest::Test
  def test_association_stuff
    post = Post.create!
    post.comments << Comment.create!

    assert_equal 1, post.comments.count
    assert_equal 1, Comment.count
    assert_equal post.id, Comment.first.post.id
  end
end