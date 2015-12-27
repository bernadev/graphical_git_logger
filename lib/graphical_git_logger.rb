# This file contains the basic code to extract all information from git
# log and manipulate it as a hash element, all through the D3 component

require "graphical_git_logger/version"

module GraphicalGitLogger
  # Gets the log file content, this should be refactored to get the log from
  # all branches in the project, by the moment just works with the current branch
  # and under the supposition that you save it in a file called git-log.txt
  def log_file
    File.read('git-log.txt')
  end

  # This is the main method, which extract the information from the
  # git log and returns the hash with the basic structure to use with D3
  def map_git_history(git_log)
    return if git_log.nil?

    commits = define_commits_by_log(git_log)
    mapped_commits = []
    commits.each do |commit|
      splitted = define_lines_by_commit(commit)
      commit_detail = remove_blanks(splitted)
      mapped_commits << commit_detail
    end
    mapped_commits
  end

  # Removes the blank or empty elements from the array after you split the text
  # from the git log, to avoid to map unnecessary elements or blank lines
  def remove_blanks(lines)
    lines.reject!(&:blank?) if lines.is_a?(Array)
  end

  # Once the text form the git log are splitted by commits, this method is used to
  # split the commit content, such as author, date, SHA, insertions, deletions etc
  def define_lines_by_commit(body)
    body.split(/\r?\n/)
  end

  # Splits the content from the git log by commits & returns an array with them
  def define_commits_by_log(log_file)
    remove_blanks(log_file.split('commit'))
  end

  # Cleans the array obtained from the splitting & builds a hash with the detail
  def make_data(commit)
    remove_blanks(commit)
    remove_extra_spaces(commit)
    build_commit_detail(commit)
  end

  # Removes the extra spaces from each line after the text is splitted
  def remove_extra_spaces(commit)
    commit.map(&:strip!) and return commit
  end

  # Builds the hash for each main element on the commit
  def build_commit_detail(commit)
    {
      sha_detail(commit),
      get_detail_for(commit[1], :author, 'Author:'),
      get_detail_for(commit[2], :date, 'Date:')
    }
  end

  # Returns a hash with the key for the commit's SHA
  def sha_detail(commit)
    { commit: commit[0] }
  end

  # This method takes a content param, which is a line from the commit's detail
  # the key that should be used to the hash & the delimiter to split the content.
  # This is a way to avoid to repeat the same functionality for each line on the
  # commit, in case that i the future the Gem shoul build a more detailed graph.
  def get_detail_for(content, key, delimiter)
    data = remove_blanks(content.split(delimiter))
    remove_extra_spaces(data) and return { key => data.first }
  end
end
