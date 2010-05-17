class UserShell
	Commands =
	[
		['?', 'prints this help', :commandHelp],
		['help', 'prints this help', :commandHelp],
		['add-name-filter <regexp>', 'add a new release name filter to your account to have new releases downloaded automatically in future', :commandAddNameFilter],
		['add-nfo-filter <regexp>', 'add a new NFO content filter to your account to have new releases downloaded automatically in future, based on their NFOs', :commandAddNFOFilter],
		['add-genre-filter <regexp>', 'add a new MP3 genre content filter to your account to have new MP3/video releases from TorrentVault downloaded automatically in future, based on the genre stated on the site', :commandAddGenreFilter],
		['list-filters', 'retrieve a list of your filters', :commandListFilters],
		['delete-filter <index 1> <...>', 'removes one or several filters which are identified by their numeric index', :commandDeleteFilter],
		['clear-filters', 'remove all your release filters', :commandClearFilters],
		['database', 'get statistics on the database', :commandDatabase],
		['search <regexp>', 'search the database for release names matching the regular expression', :commandSearch],
		['download <name>', 'start the download of a release from the first site that matches the name', :commandDownload],
		['download-by-id <site> <id>', 'download a release from a specific source (site may be scc or tv, e.g.)', :commandDownloadByID],
		['status', 'retrieve the status of downloads in progress', :commandStatus],
		['cancel', 'cancel a download', :commandCancel],
		['permissions', 'view your permissions/limits', :commandPermissions],
		['exit', 'terminate your session', :commandExit],
		['quit', 'terminate your session', :commandExit],
		['ssh <SSH key data>', 'set the SSH key in your authorized_keys to authenticate without a password prompt', :commandSSH],
		['regexp-help', 'a short introduction to the regular expressions used by this system', :commandRegexpHelp],
		['category <path> <filter 1> <...>', 'assign a folder to a set of filters', :commandCategory],
		['delete-category <path>', 'get rid of a symlinks folder', :commandDeleteCategory],
		
		['read-logs <user 1> <...>', 'read the commands typed by users or a single user', :commandReadCommandLogs, true],
	]
end
