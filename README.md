# AMAT 5315 - Modern Scientific Computing: Homeworks

[A step-by-step guide about the workflow - Yidai Zhang](https://code.hkust-gz.edu.cn/jinguoliu/ModernScientificComputing2024/-/blob/main/Lecture1/livecoding.md?ref_type=heads)

## How to submit your homework?
1. Fork this repository to your own account
2. Clone your forked repository to your local machine
3. Add your work to the corresponding folder, e.g.
   ```bash
   hw1/yidaizhang/
   ```
   where `yidaizhang` should be replaced by your own name in lower case and `hw1` should be replaced by the correct homework number.
4. Commit your changes and push the changes to your remote repository
5. Create a pull request (or merge request) to the original repository. The title should be the same as the folder name, e.g. `hw1/yidaizhang` in the above example.
6. If you receive feedback from the instructor or the TA, please update your homework and the corresponding pull request (PR). Your homework will be graded after the PR is merged.

## How to fix your homework
It is simple, just
```bash
git add -a
git commit -m 'some messsage'
git push
```

## How to submit another homework?
1. Update your forked repository to the latest version of the original repository
   ```bash
   git remote add upstream https://code.hkust-gz.edu.cn/jinguoliu/amat5315courseworks2024.git
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```
2. Checkout a new branch for your homework, e.g.
   ```bash
   git checkout -b hw2/yidaizhang
   ```
3. Add your work to the corresponding folder, `hw2/yidaizhang/` in the above example.
4. Create a pull request (or merge request) to the original repository. The rest of the steps are the same as the first time.

## How to seek for help?
Please file an [issue](https://code.hkust-gz.edu.cn/jinguoliu/amat5315courseworks2024/-/issues)!
