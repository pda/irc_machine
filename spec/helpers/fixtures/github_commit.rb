module Fixtures

  class GithubCommit; class << self

    def new
      commit = github_payload
      ::IrcMachine::Models::GithubCommit.new({
        repo: "Fixture",
        commit: commit,
        repo_name: commit.repository.name,
        branch_name: commit.branch
      })
    end

    def github_payload
      # Template stolen from http://help.github.com/post-receive-hooks/
      # FIXME
      # { #{{{ Github Payload
      #   :before     => before,
      #   :after      => after,
      #   :ref        => ref,
      #   :commits    => [{
      #   :id        => commit.id,
      #   :message   => commit.message,
      #   :timestamp => commit.committed_date.xmlschema,
      #   :url       => commit_url,
      #   :added     => array_of_added_paths,
      #   :removed   => array_of_removed_paths,
      #   :modified  => array_of_modified_paths,
      #   :author    => {
      #   :name  => commit.author.name,
      #   :email => commit.author.email
      # }
      # }],
      #   :repository => {
      #   :name        => repository.name,
      #   :url         => repo_url,
      #   :pledgie     => repository.pledgie.id,
      #   :description => repository.description,
      #   :homepage    => repository.homepage,
      #   :watchers    => repository.watchers.size,
      #   :forks       => repository.forks.size,
      #   :private     => repository.private?,
      #   :owner => {
      #   :name  => repository.owner.login,
      #   :email => repository.owner.email
      # }
      # }
      # } #}}}
      OpenStruct.new({
        repository: OpenStruct.new({
          name: "Fixture"
        }),
        branch: "FixtureBranch"
      })
    end
  end; end

end
