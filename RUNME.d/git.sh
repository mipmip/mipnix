make_command "git_sync_machine" "Commit latest version with hostname tag"
git_sync_machine(){
  if [[ -z "$EXTRA_ARG" ]]; then
    echo "Please enter a small commit message"
    exit 1
  fi
  git commit -m "$EXTRA_ARG" -a
  # Tag with the machine the change targets. Remote deploys set SYNC_TARGET to
  # the deployed host; local rebuilds leave it unset and fall back to the
  # machine running the command (which is the one being rebuilt).
  TAG_NAME="${SYNC_TARGET:-$(hostname)}-$(date --iso-8601)"
  # Remove existing tag locally and remotely if it exists
  git tag -d "$TAG_NAME" 2>/dev/null || true
  git push origin --delete "$TAG_NAME" 2>/dev/null || true
  # Create new tag and push
  git tag "$TAG_NAME"
  git push origin "$TAG_NAME"
  git push
}
