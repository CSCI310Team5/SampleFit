#  Tasks

## Me
1. Add a change password button to Me.

## UserDetail
1. Implement UserDetail

## Authentication
1. Replace username with email as the unique identifier.
2. Extract password validation code into Network Query Controller

## Me -> Uploads
1. Implement add new upload.

## ExerciseDetail
1. Start / Stop exercise should be really calling functions

## Networking
1.  Extract loading favorites / Uploads / Following into NetworkQueryController. These should load right after user login, but on a background thread.
2.  Anytime publicProfile / personalInformation changes, we should sync changes over network.
