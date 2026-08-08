# Role: proc_hidepid

Mounts `/proc` with `hidepid=2` (or respects `0` for container nodes) to prevent non-root users from viewing processes owned by other users.
