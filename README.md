# AMAT 5315 - Modern Scientific Computing: Homeworks

## The workflow to set up the environment
This tutorial is mainly based on macOS. If you are using Windows, you can check the previous tutorial [here](https://code.hkust-gz.edu.cn/jinguoliu/ModernScientificComputing2024/-/blob/main/Lecture1/livecoding.md?ref_type=heads) (need HKUST-GZ network). If you encounter any problems, please feel free to ask for help in the [issue](https://code.hkust-gz.edu.cn/jinguoliu/amat5315courseworks2024/-/issues), our Zulip channel, or wechat TA (Zhongyi Ni).

### Step 1: Install Git and sign up for a GitHub account
 If you already have Git installed and a GitHub account, you can skip this step.
Follow the instructions [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) to install Git and sign up for GitHub in [here](https://github.com/signup).

### Step 2: Generate an SSH key
Type the following command in the terminal to generate an SSH key:
```bash
ssh-keygen
```
Type enter to use the default location `~/.ssh`. Then, type the following command to copy the SSH key to the clipboard:
```bash
pbcopy < ~/.ssh/yourfilename.pub
```
Remember to replace `yourfilename.pub` with the name of your SSH key. Then go to your GitHub account, click on your profile picture, and select `Settings`. Click on `SSH and GPG keys` and then click on `New SSH key`. Paste the SSH key into the `Key` field and click on `Add SSH key`.

For more information about SSH keys, you can check [here](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh).

### Step 3: Fork the course repository and clone it to your local machine
Open the [GitHub repository](https://github.com/CodingThrust/AMAT5315-2025Spring-Homeworks), click the fork button. Then you will have a new copy of the original repository with the write permission. Open the forked repository, click on the green `Code` button, and copy the SSH link.

Open a terminal and move to the directory where you want to clone the repository. Then type the following command to clone the repository to your local machine:
```bash
git clone # paste the SSH link you copied
```
Remember to paste the SSH link you copied after `git clone`.

**You only need to do the above steps once. Every time you want to submit a homework, you don't need to do the above steps again.**

## How to submit your homework?
1. Add your work to the corresponding folder, e.g.
   ```bash
   hw1/yidaizhang/
   ```
   where `yidaizhang` should be replaced by your own name in lower case and `hw1` should be replaced by the correct homework number.
2. Finish your homework in this folder.
3. Commit your changes and push the changes to your remote repository with the following commands:
   ```bash
   git add -A
   git commit -m 'some message'
   git push
   ```
4. Create a pull reques to the original repository by clicking the `Contribute` button and then `Open pull request` or click `Compare & pull request to create a pull request`.
5. Rename the title as the same as the folder name, e.g. `hw1/yidaizhang` in the above example.
6. Click `Create pull request`.
7. If you receive feedback from the instructor or the TA, please update your homework and push the changes to the remote repository with the following commands: 
   ```bash
   git add -A
   git commit -m 'some messsage'
   git push
   ```
8. Your homework will be graded after the PR is merged.

## How to submit another homework?
1. Update your forked repository to the latest version of the original repository
   ```bash
   git remote add upstream https://github.com/CodingThrust/AMAT5315-2025Spring-Homeworks
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```
2. Checkout a new branch for your homework, e.g.
   ```bash
   git checkout -b hw2/yidaizhang
   ```
3. Add your work to the corresponding folder, `hw2/yidaizhang/` in the above example.
4. Create a pull request to the original repository. The rest of the steps are the same as the first time.

## How to seek for help?
Please file an [issue](https://code.hkust-gz.edu.cn/jinguoliu/amat5315courseworks2024/-/issues)!
