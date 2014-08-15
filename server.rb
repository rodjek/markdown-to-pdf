require 'sinatra'
require 'octokit'
require 'dotenv'
require 'pdfkit'

Dotenv.load

module MarkdownToPDF
  class App < Sinatra::Base

    def nwo
      "#{params["owner"]}/#{params["repo"]}"
    end

    def path
      params["path"].gsub /\.pdf$/, ".md"
    end

    def ref
      params["ref"]
    end

    def client
      @client ||= Octokit::Client.new :access_token => ENV["GITHUB_TOKEN"]
    end

    def markdown
      response = client.contents nwo, { :path => path, :ref => ref }
      Base64.decode64 response.content
    end

    def html
      client.markdown markdown, :context => nwo
    end

    def stylesheet
      File.expand_path "bower_components/bootstrap/dist/css/bootstrap.css", File.dirname( __FILE__ )
    end

    def kit
      @kit ||= begin
        kit = PDFKit.new(html, :page_size => 'Letter')
        kit.stylesheets << stylesheet
        kit
      end
    end

    get "/:owner/:repo/blob/:ref/:path" do
      content_type "application/pdf"
      kit.to_pdf
    end

  end
end
