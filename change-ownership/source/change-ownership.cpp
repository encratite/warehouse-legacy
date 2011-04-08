#include <iostream>
#include <string>
#include <stdexcept>
#include <cstdio>
#include <vector>
#include <algorithm>

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <pwd.h>
#include <grp.h>

typedef std::vector<gid_t> gidVector;

namespace
{
  //this macro is specified by the build shell script
  std::string const permittedGroup = CHANGE_OWNERSHIP_GROUP;
}

void printUsage(char ** argv)
{
  std::cout << "Usage:" << std::endl;
  std::cout << argv[0] << " <user> <path>" << std::endl;
}

gidVector getUserGroups(std::string const & user, passwd * passwordData)
{
  int groupCount;
  gidVector groups(sysconf(_SC_NGROUPS_MAX) + 1);
  int result = getgrouplist(user.c_str(), passwordData->pw_gid, &groups.front(), &groupCount);
  if(result == -1)
    throw std::runtime_error("Failed to retrieve the list of groups associated with the user");

  groups.resize(groupCount);

  return groups;
}

bool contains(gidVector const & container, gid_t value)
{
  return std::find(container.begin(), container.end(), value) != container.end();
}

void changeOwnership(std::string const & newOwner, std::string const & newGroup, std::string const & path)
{
  passwd * myEffectivePasswordData = getpwuid(geteuid());
  if(myEffectivePasswordData == NULL)
    throw std::runtime_error("Failed to look up your effective user name");
  std::string myEffectiveUserName = myEffectivePasswordData->pw_name;

  if(myEffectiveUserName != "root")
    throw std::runtime_error("You need to run this program with super user privileges");

  passwd * myActualPasswordData = getpwuid(getuid());
  if(myActualPasswordData == NULL)
    throw std::runtime_error("Failed to look up your user name");
  std::string myActualUserName = myActualPasswordData->pw_name;

  group * groupData = getgrnam(newGroup.c_str());
  if(groupData == NULL)
    throw std::runtime_error("Unable to retrieve group data");

  gidVector myGroups = getUserGroups(myActualUserName, myActualPasswordData);
  if(!contains(myGroups, groupData->gr_gid))
    throw std::runtime_error("You are not a member of the permitted group");

  passwd * newOwnerPasswordData = getpwnam(newOwner.c_str());
  if(newOwnerPasswordData == NULL)
    throw std::runtime_error("Unable to retrieve the user ID of the new owner");

  gidVector targetGroups = getUserGroups(newOwner, newOwnerPasswordData);
  if(!contains(targetGroups, groupData->gr_gid))
    throw std::runtime_error("The new owner is not a member of the permitted group");

  struct stat fileInformation;
  int result = stat(path.c_str(), &fileInformation);
  if(result == -1)
    throw std::runtime_error("Unable to retrieve file information");

  if(fileInformation.st_uid == geteuid())
    throw std::runtime_error("You may not change the ownership of files of the super user");

  if
    (
     fileInformation.st_uid != getuid() &&
     fileInformation.st_gid != groupData->gr_gid
     )
    throw std::runtime_error("The target file must be either owned by you or by the group in question");

  result = chown(path.c_str(), newOwnerPasswordData->pw_uid, groupData->gr_gid);
  if(result == -1)
    throw std::runtime_error("Unable to change the ownership of the file in question");
}

int main(int argc, char ** argv)
{
  if(argc != 3)
    {
      printUsage(argv);
      return 1;
    }

  try
    {
      changeOwnership(argv[1], permittedGroup, argv[2]);
    }
  catch(std::runtime_error & exception)
    {
      std::cout << "An exception occured: " << exception.what() << std::endl;
      return 1;
    }

  return 0;
}
