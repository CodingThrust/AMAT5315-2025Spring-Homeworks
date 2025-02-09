# AMAT 5315 - Modern Scientific Computing: Homeworks

## The workflow to set up the environment
This tutorial is mainly based on macOS. If you encounter any problems, please feel free to ask for help in the [issue](https://code.hkust-gz.edu.cn/jinguoliu/amat5315courseworks2024/-/issues), our Zulip channel, or wechat TA (Zhongyi Ni).

### Step 1: Install Git and sign up for a GitHub account
 If you already have Git installed and a GitHub account, you can skip this step.
Follow the instructions [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) to install Git and sign up for GitHub in [here](https://github.com/signup).

### Step 2: Generate an SSH key
Type the following command in the terminal to generate an SSH key:
```bash
ssh-keygen
```
Type enter to use the default location `~/.ssh`. Then, use the following command to copy the SSH key to the clipboard:
```bash
cat ~/.ssh/yourfilename.pub  # copy the output to the clipboard
```
Remember to replace `yourfilename.pub` with the name of your SSH key. Then go to your GitHub account, click on your profile picture, and select `Settings`. Click on `SSH and GPG keys` and then click on `New SSH key`. Paste the SSH key into the `Key` field and click on `Add SSH key`.

For more information about SSH keys, you can check [here](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh).

### Step 3: Fork the course repository and clone it to your local machine
Open the [GitHub repository](https://github.com/CodingThrust/AMAT5315-2025Spring-Homeworks), click the fork button. Then you will have a new copy of the original repository with the write permission. Open the forked repository, click on the green `Code` button, and copy the SSH link.

Open a terminal and move to the directory where you want to clone the repository. Then type the following command to clone the repository to your local machine:
```bash
git clone <the SSH link you copied>
git remote add upstream https://github.com/CodingThrust/AMAT5315-2025Spring-Homeworks.git
git remote -v  # check the remotes
```
In the second line, we added the original repository as a remote called `upstream`. This is useful when you want to update your local repository to the latest version of the original repository.

**You only need to do the above steps once. Every time you want to submit a homework, you don't need to do the above steps again.**

## How to submit your homework?
1. (create a working branch) Create a new branch and create a working directory corresponding to the homework, e.g.
   ```bash
   git checkout main   # switch to the main branch
   git pull upstream   # sync the main branch with the upstream
   git checkout -b hw1/zhongyini   # create a new branch for the homework
   mkdir hw1/zhongyini/  # create a working directory for the homework
   ```
   where `zhongyini` should be replaced by your own name in lower case and `hw1` should be replaced by the correct homework number.
2. (finish your homework) Finish your homework in this folder. The homework description is in the `hw1/README.md` file.
3. (save your work) Commit your changes and push the changes to your remote repository with the following commands:
   ```bash
   git add -A
   git commit -m 'some message'
   git push
   ```
4. (submit your work) Go to the forked repository webpage, click on the `Contribute` button and then `Open pull request` or click `Compare & pull request to create a pull request`. The title should be the same as the folder name, e.g. `hw1/zhongyini` in the above example. After clicking `Create pull request`, you can see the PR on the webpage.
5. (correct your homework) If you receive feedback from the instructor or the TA, please update your homework and push the changes to the remote repository with the following commands: 
   ```bash
   git add -A  # make sure your are in the right working branch
   git commit -m 'some messsage'
   git push
   ```
6. Your homework will be graded after the PR is merged.