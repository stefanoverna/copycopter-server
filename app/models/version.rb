class Version < ActiveRecord::Base
  # Attributes
  attr_accessible :content, :published

  # Associations
  belongs_to :localization

  # Validations
  validates_presence_of :localization_id

  # Callbacks
  before_validation :set_number, :on => :create
  after_create :update_localization
  after_create :update_project_caches, :unless => :first_version?

  def revise(attributes = {})

    if attributes[:content] && localization.blurb.html?
      config = Sanitize::Config.merge(
        Sanitize::Config::BASIC,
        elements: Sanitize::Config::BASIC[:elements] + %w(h1 h2 h3 h4 h5 h6 hr table tr td th tbody thead),
        attributes: Sanitize::Config::BASIC[:attributes].merge(
          all: ['id', 'class'],
          'td' => ['colspan', 'rowspan'],
          'th' => ['colspan', 'rowspan']
        ),
        allow_comments: false,
        remove_contents: %w(meta style)
      )
      text = Sanitize.clean(attributes[:content], config).strip
      text.gsub!(/%%7b([^%]+)%7d/i, '%{\1}')

      attributes[:content] = text
    end

    localization.
      versions.
      build self.attributes.merge('published' => published).merge(attributes)
  end

  def project
    localization.project
  end

  def published=(published)
    @publish_after_saving =
      ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(published)
  end

  def published
    if new_record?
      publish_after_saving?
    else
      localization.published_version_id == id
    end
  end

  def published?
    published
  end

  private

  def publish_after_saving?
    @publish_after_saving
  end

  def set_number
    if !number && localization
      self.number = localization.next_version_number
    end
  end

  def update_localization
    unless first_version?
      localization.update_attributes! :draft_content => content
    end

    if publish_after_saving?
      localization.publish
    end
  end

  def update_project_caches
    project.update_caches
  end

  def first_version?
    number == 1
  end
end

