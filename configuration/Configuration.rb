require 'nil/file'

#this is intended to provide local configuration overrides for testing/debugging purposes without messing with the repository contents
def loadConfigurationFiles
	baseDirectory = 'configuration'
	
	mainDirectory = 'Configuration'
	customDirectory = 'myConfiguration'
	
	mainPath = Nil.joinPaths(baseDirectory, mainDirectory)
	customPath = Nil.joinPaths(baseDirectory, customDirectory)
	
	targets = Nil.readDirectory(mainPath)
	targets.each do |target|
		customPath = Nil.joinPaths(customPath, target.name)
		if File.exists?(customPath)
			require customPath
		else
			require target.path
		end
	end
end

loadConfigurationFiles
