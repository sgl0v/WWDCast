# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"
has_app_changes = !git.modified_files.grep(/Sources/).empty?

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR, try to keep changes smaller if you can") if git.lines_of_code > 500

# Ensure a clean commits history
if git.commits.any? { |c| c.message =~ /^Merge branch '#{github.branch_for_base}'/ }
  fail "Please rebase to get rid of the merge commits in this PR"
end

# Warn when project files has been updated but not tests.
tests_updated = !(git.added_files.grep(/Tests.*\.swift/).empty?)
if has_app_changes && !tests_updated
  warn("The project files were changed, but the tests remained unmodified. Consider updating or adding to the tests to match the project changes.")
end

# Run SwiftLint
swiftlint.lint_files