# In case you missed them, here are the extensions: http://guides.rubyonrails.org/active_support_core_extensions.html

require 'active_support/all'

class BlagPost
  attr_accessor :author, :comments, :categories, :body, :publish_date

  Author = Struct.new(:name, :url)
  DISALLOWED_CATEGORIES = [:selfposts, :gossip, :bildungsromane]

  def initialize(args)
    args.symbolize_keys!

    @author = check_author(args[:author], args[:author_url])
    @categories = check_categories(args[:categories]) if args[:categories]
    @comments = args[:comments] || []
    @body = check_body(args[:body])
    @publish_date = check_date(args[:publish_date])
  end

  def to_s
    [ category_list, byline, abstract, commenters ].join("\n")
  end

  private

  def check_body(body)
    return body ? body.squish : ''
  end

  def check_author(author, author_url)
    return nil unless author.present? && author_url.present?
    Author.new(author, author_url)
  end

  def check_categories(categories)
    categories.reject { |category| category.in? DISALLOWED_CATEGORIES }
  end

  def check_date(date)
    return date ? date.to_date : Date.today
  end

  def byline
    author.try { |a| "By #{a.name}, at #{a.url}" }
  end

  def category_list
    return "" if !categories || categories.empty?

    "Category".pluralize(categories.length) + ": " + categories.map { |cat| as_title(cat) }.to_sentence
  end

  def as_title(string)
    string.to_s.titleize
  end

  def commenters
    return '' unless comments_allowed? || comments.any?

    "You will be the #{(comments.length + 1).ordinalize} commenter"
  end

  def comments_allowed?
    publish_date + 3.years > Date.today
  end

  def abstract
    body.truncate(204)
  end

end

blag = BlagPost.new("author"        => "Foo Bar",
                    "author_url"    => "http://www.google.com",
                    "categories"    => [:theory_of_computation, :languages, :gossip],
                    "comments"      => [ [], [], [] ], # because comments are meaningless, get it?
                    "publish_date"  => "2013-02-10",
                    "body"          => <<-ARTICLE
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a diam lectus.
                        Sed sit amet ipsum mauris. Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit.
                        Donec et mollis dolor. Praesent et diam eget libero egestas mattis sit amet vitae augue. Nam
                        tincidunt congue enim, ut porta lorem lacinia consectetur. Donec ut libero sed arcu vehicula
                        ultricies a non tortor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean ut
                        gravida lorem. Ut turpis felis, pulvinar a semper sed, adipiscing id dolor. Pellentesque auctor
                        nisi id magna consequat sagittis. Curabitur dapibus enim sit amet elit pharetra tincidunt feugiat
                        nisl imperdiet. Ut convallis libero in urna ultrices accumsan. Donec sed odio eros. Donec viverra
                        mi quis quam pulvinar at malesuada arcu rhoncus. Cum sociis natoque penatibus et magnis dis
                        parturient montes, nascetur ridiculus mus. In rutrum accumsan ultricies. Mauris vitae nisi at sem
                        facilisis semper ac in est.
                        ARTICLE
                   )
puts blag.to_s
