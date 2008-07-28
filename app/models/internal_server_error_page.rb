class InternalServerErrorPage < Page

  description %{
    An "Internal Server Error" page can be used to override the default
    error page in the event that a request raises an unhandled exception.

    To create an "Internal Server Error" error page for an entire Web site,
    create a page that is a child of the root page and assign it
    "Internal Server Error" page type.
  }

  def virtual?
    true
  end

  def headers
    { 'Status' => '500 Internal Server Error' }
  end

  def cache?
    false
  end

end
