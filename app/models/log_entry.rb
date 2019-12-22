class LogEntry < ApplicationRecord
  belongs_to :user, required: true
  validates :day, :details, presence: true
  validates :day, uniqueness: { scope: :user_id }
  validate :details_html_is_valid

  private

  EXEMPTED_TAGS = Set['p', 'br', 'img', 'param', 'li']
  FORBIDDEN_TAGS = Set['html', 'body', 'table', 'tr', 'th', 'td', 'script', 'frame']

  # Enforce proper nesting (except for exempted tags) and no forbidden tags.
  def details_html_is_valid
    tags = details.downcase.scan(/<(\/?[a-zA-Z]+)/)
    stack = []
    tags.flatten.each do |tag|
      if tag[0] == '/'
        open_tag = tag[1..]
        continue if EXEMPTED_TAGS.include?(open_tag)
        break if check_forbidden_tag(open_tag)
        if stack.empty? || !stack.pop == open_tag
          log_malformed_html
          break
        end
      else
        continue if EXEMPTED_TAGS.include?(tag)
        break if check_forbidden_tag(tag)
        stack.push(tag)
      end
    end
    log_malformed_html if !stack.empty?
  end

  def check_forbidden_tag(tag)
    errors[:base] << 'Your entry included a forbidden HTML tag.' if FORBIDDEN_TAGS.include?(tag)
  end

  def log_malformed_html
    errors[:base] << 'Your entry contained malformed HTML. Please nest your tags properly.'
  end
end
