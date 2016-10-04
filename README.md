# Dwarf 4tress From Scratch
### Download: from the [release menu](https://github.com/LordCerapter/D4FS/releases).

Dwarf 4tress From Scratch (pronounced like 'Dwarf Fortress From Scratch') is the fourth iteration of the community Bay12Forums project, 'Dwarf Fortress From Scratch', based on the video game 'Slaves to Armok: God of Blood - Chapter II: Dwarf Fortress', or, as more commonly known, 'Dwarf Fortress'.

If you are unfamiliar with the game, you may download it [here][1]. After that, you may partake in this project by first registering on the [official forums][2]. This is, of course, not a hard prerequisite -- however, we would like to know who is developing for the project.

This project is a mixture of a [modding project](http://dwarffortresswiki.org/index.php/DF2014:Modding_guide) and a standard playthrough of the game. The participants are divided into two groups, Players and Modders (though worry not; these groups are not mutually exclusive nor binding -- you may join the other group at any time). 

The Players simply download the current version of the master branch of this mod, and play it. They then write about the happenings in their game, about what they found interesting, if they found bugs, or anything, really. They may also post screenshots alongside the story.
Again, please note that is not a hard prerequisite. You may enjoy the game without our knowledge, too, obviously.

The Modders, on the other hand, add more to the project by creating new creatures, stones, buildings, items, etc. It is beneficial for them to know about basic Git(hub) usage, however it is not required. If they had created something, but cannot use Git(hub), they may ask [Cerapter](http://www.bay12forums.com/smf/index.php?action=profile;u=107094) on the Bay12Forums, [LordCerapter](https://github.com/LordCerapter) on GitHub (both being the same person), or any modders currently participating in the project, and they will upload in their stead.

Navigate to the project's thread [with this link][3].

---

## Players' Guide
(This guide assumes you can download files, unpackage packaged files, launch executables, and can do basic file modifications, such as copying, pasting, and deleting.)

1. Obtain the [game][1].
2. Download the Project's latest version from the [release menu](https://github.com/LordCerapter/D4FS/releases).
3. Back up the game's original files.
4. In the game's files, remove the `raw` folder.
5. Move, or copy and paste the downloaded Project's `data` and `raw` folders into the game's folder, where the original folders used to be.
  + You must overwrite the `data` folder.
  + Now, the game will use the project's files.
6. Launch the game.
Additionally:
7. Your game will generate a file in the same folder as your executable, called `errorlog.txt`. Post its contents on the forums.
  + Please note that it does not empty itself, meaning that errors from previous playthroughs will still be in there when you start a new game. You may manually erase the errors you have already posted on the forums.
  + If this file does not appear, then we have made a version without errors. Do not worry about it, then.

---

## Modders' Guide
We have several standards that we require you to follow. These are not overly tyrannical ones (at least, we hope so), but rather, are implemented so that the RAWs (and DATA files) are easy to read and modify. You may check these on the Project's [wiki](https://github.com/LordCerapter/D4FS/wiki).

### If you do not desire to use Git:

1. Proceed as you would have if you were a Player.
2. Make any changes you wish.
3. Package the file, upload it somewhere.
  + The [Dwarf Fortress File Depot](http://dffd.bay12games.com/index.php) is generally a good place to keep things such as this.
4. Send your package to either:
  + [Cerapter](http://www.bay12forums.com/smf/index.php?action=profile;u=107094) on the Bay12Forums.
  + [LordCerapter](https://github.com/LordCerapter).
  + [Any contributor](https://github.com/LordCerapter/D4FS/graphs/contributors).
  + [Any Modder][3] in the forum thread. (Assuming they know how to use Git.)
5. We will deal with the rest.

### If you are using Github:
**Note**: alert [Cerapter](http://www.bay12forums.com/smf/index.php?action=profile;u=107094) or [LordCerapter](https://github.com/LordCerapter) to be made a collaborator in the project, so that you could make branches instead of having to fork the project everytime you want to make a modificiation.

1. Fork the project onto your own Github page.
  + You may perform this by navigating to the Project's Github page (you are most likely here), and pressing the 'Fork' button on the upper right corner.
  + Forking means that you want a copy of the Project to play around in.
2. Make the changes. You do not need any unconventional knowledge here: just download your own fork, fiddle around with it, then use the 'Upload files' button to update.
3. After you are done, submit a 'Pull request' on the Project's Github page, using the 'New pull request' button.
  + To pull is to implement all the changes into the master branch, from another branch or fork.
  + A pull request, thus, is a way to ask the Project's lead to do that with your fork.
  + Please note that you will most likely want to press the 'compare across forks' link to be able to choose your own fork.

### If you are using Git:
This guide assumes you are using a Git manager with a graphical user interface. In fact, this tutorial was written with [GitKraken](https://www.gitkraken.com/) in mind, however, most of this writing should be true for all Git managers.

1. Open up your favourite Git manager.
  + Also, you might want to make a folder in which you will keep your project clones (more on that later). Naming it something like "git" should suffice.
2. Clone a project.
  + Cloning means having a local copy of the project on your computer.
3. You will most likely be asked WHERE TO clone it. This is just the place you want to put the clone into. Choose the previously made 'git' folder.
4. Then you will be asked an URL. This asks what do you want to clone. Input this:
  + https://github.com/LordCerapter/D4FS.git
5. If at any point, your Git Manager asks for a name and an e-mail, input the ones you used for Github registration.
  + Later on, it will also ask your Github password. It needs that to log-in to Github to be able to modify the project.
6. Search for a 'pull' button or command and use it.
  + This will request all the current files in the Project, and download it onto your computer.
7. Play around with the files on your computer, modifying what you want.
8. After that:
  + Your Git manager might noticed you modifying the local files and alerted you of "unstaged files".
  + If it does not, see later.
9. If needed, select all the files you have modified and 'stage' them.
  + If you have a 'stage all changes' button, use that.
  + Staging does not "upload" anything yet to the Project. It is merely a "plan" of sorts, a plan of what you will later commit.
10. Commit your changes.
  + Committing means you finalise your modifications and send it to the Project's lead, who will decide on its inclusion.
  + You will be asked to provide a Commit Message.
  + For summary, write a short message about what changes you have made.
  + For description, write about your changes in detail.
  + Though not required, please also mark who you are on the Bay12Forums.

If you are making larger modifications, you may also want to make a branch.

---

## Credits
+ The original participants of the previous three projects.
+ The ORIGINAL participants of the very first project. This could not have happened without you guys. Special thanks to:
  + [Halfling](http://www.bay12forums.com/smf/index.php?action=profile;u=93250), the first project's starter, and the guy whose RAWs we are still using up to this day.
  + [vyznev](http://www.bay12forums.com/smf/index.php?action=profile;u=21867), who has created various utilities to ease DATA file modification and to check RAW file integrity.

[1]: http://www.bay12games.com/dwarves/
[2]: http://www.bay12forums.com/smf/index.php
[3]: http://www.bay12forums.com/smf/index.php?topic=158283.0 "The Project's Forum Thread"
