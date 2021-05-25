# Report MNT-Lab/git-module212 (branch)

## DevOps Lab Apr2021<br>
EPAM<br>
#DevOps<br>

<img
src="../02Git/images/git.png"
height=48 width=48 alt="Git Logo" />

---

### Исходные данные

Основные задачи сформулированы в [задании](../02Git/README.md).

---

### Результаты изложены ниже:

<details><summary>Подготовка</summary>
<p>

#### Подготовка:

<li> Создание текущей ветки (branch): branch </li>

```
git clone ssh://github.com/MNT-Lab/git-module212.git
git checkout -b branch
git push --set-upstream origin branch
```

<li> Создание нового подключения к ветке branch (например на др. ПК) </li>

```
git clone ssh://github.com/MNT-Lab/git-module212.git
git checkout branch
```

</p>
</details>

<details><summary>01. Просмотр видео </summary>
<p>

#### Просмотр видео:

Данный материал был пройден в курсе [Version Control with Git](https://elearn.epam.com/courses/course-v1:EPAM+VCG+RU/course/) by Vitali Shulha.

</p>
</details>

<details><summary>02. Learn Git Version Control </summary>
<p>

[Learn Git Version Control](https://www.katacoda.com/courses/git)

В процессе выполнения сценариев были использованы команды (опубликованы без повторов):

<li>Scenario 1 - Committing Files</li>

```
git init
git status
git add hello-world.js
git commit -m "#1 commit"
touch .gitignore
echo "*.tmp" > ./.gitignore #File add & commit
```

<li>Scenario 2 - Committing Changes</li>

```
git diff
git difftool
git diff --staged
git log
git log --pretty=format:"%h %an %ar - %s"
git show
git show 6d78fd5
```

<li>Scenario 3 - Working Remotely</li>

```
git remote add origin  /s/remote-project/1
git push --set-upstream origin master
git pull
git log --grep="#1234"
git fetch
git branch -r
```

<li>Scenario 4 - Undoing Changes</li>

```
git checkout
git reset
git reset --hard
git reset --hard fe2649
git reset HEAD~1
vi ./staging.txt
git revert 2864796
git revert HEAD...HEAD~2
git log --oneline
```

<li>Scenario 5 - Fixing Merge Conflicts</li>

```
git mergetool --tool-kdiff3 staging.txt
git checkout --theirs staging.txt
git reset --hard HEAD
git commit --no-edit
git pull --no-edit origin master
git log --all --decorate --oneline
git rebase master
git pull --rebase
```

<li>Scenario 6 - Experiments Using Branches</li>

```
git checkout -b new_branch
git branch
git branch -va
git checkout master
git merge new_branch
git push origin new_branch
git branch -d new_branch
```

<li>Scenario 7 - Finding Bugs</li>

```
git diff HEAD~2 HEAD
git log --oneline
git log -p
git log -p -n 2
git log --grep="Initial"
git bisect start
git bisect bad
git bisect good HEAD~5
cat list.html
git bisect good
cat list.html
git bisect bad
git blame list.html
git blame -L 6,8 list.html
```


<li>Scenario 8 - Being Picky With Git</li>

```
git log --pretty=oneline --reverse new_branch
git cherry-pick 33mcf6a435e19316bbf4703ee136dc7beb7929f2d1fESC
git cherry-pick new_branch~1
git add list2.html
git cherry-pick --continue
```

<li>Scenario 9 - Re-writing History</li>

```
git rebase --interactive --root #change pick to reword
git commit --amend
git rebase --interactive HEAD~8 #change pick to squash #2-8
git rebase --interactive HEAD~2 #reorder the lines
git rebase --interactive HEAD~1
git reset HEAD^
git add file3.txt
git commit -m "File 3"
git add file4.txt
git commit -m "File 4" 
git rebase --continue
git log --oneline
```

</p>
</details>

<details><summary>03. Git SCM - Lab 101 </summary>
<p>

[Git SCM - Lab 101](https://www.katacoda.com/aossama/scenarios/git-scm-lab-101)

В процессе выполнения сценария были использованы команды (опубликованы без повторов):

```
git init # Add files README.md  index.html
git config --global user.email "test@example.com"
git config --global user.name "Test"
git config --list
git add README.md index.html
git commit -m "Initial commit" # Add files file.tmp .gitignore
git add .gitignore
git commit -m "Adding .gitignore"
git log --oneline
git log --graph --oneline --decorate
git log --pretty=format:"%cn committed %h on %cd"
git log -3
git log --after="2017-12-10"
git log --after="10 minutes ago"
git log --after="2017-10-10" --before="2017-12-10"
git log --author="Test" #Edit README.md
git diff README.md
git diff --color-words
git diff
git commit --all --message="Modify README.md" #Add style.css 
git status
git stash list
git stash save --include-untracked "Stashing the stylesheet"
git status
git stash list
git stash pop
git add style.css
git commit --all --message="Add stylesheet style.css"
git remote add origin http://git.itworx.cloud/Test/simple-html-project.git
git push -u origin master
```

</p>
</details>

<details><summary>04. Git SCM - Lab 102 </summary>
<p>

[Git SCM - Lab 102](https://www.katacoda.com/aossama/scenarios/git-scm-lab-102)

В процессе выполнения сценария были использованы команды:

```
git clone https://github.com/aossama/simple-html-app.git
cd simple-html-app/
git remote
git remote -v
git remote rename origin old-origin
git remote add origin http://git.itworx.cloud/Test/simple-html-app.git
git remote -v
git push -u origin --all #Add Apache License 2.0 on  http://git.itworx.cloud/Test
git fetch origin
git diff master origin/master
git merge origin/master #Add CHANGELOG on  http://git.itworx.cloud/Test
git pull origin
```

</p>
</details>

<details><summary>05. Git SCM - Lab 201 </summary>
<p>

[Git SCM - Lab 201](https://www.katacoda.com/aossama/scenarios/git-scm-lab-201)

В процессе выполнения сценария были использованы команды:

```
git clone http://git.itworx.cloud/Test/simple-html-app.git
git branch
git branch my-feature
git branch delete-me
git checkout my-feature
git branch #Add about.html
git add about.html
git commit -m 'Add about us page' #Add delete-me.html
git add delete-me.html
git commit -m 'To be deleted later on'
git push -u origin my-feature
git checkout master
git branch -d delete-me
git branch -D delete-me
git push origin --delete my-feature
git checkout demo-feature
git checkout -b stable
git checkout  -b unstable stable
git checkout stable
git fetch --all
git tag -a v1.4 -m "my version 1.4"
git tag v1.4-lw
git tag v1.4-rc
git tag v1.5-rc
git tag -a v1.5 -m "my version 1.5"
git tag
git tag -l *-rc
git push origin v1.4
git push origin --tags
git checkout v1.4
git checkout master
git tag
git tag -d v1.4-lw
git status
git checkout master
git fetch
git pull
git branch --no-merged
git merge my-feature
git push
git branch -d my-feature
```

</p>
</details>

<details><summary>06. Git SCM - Lab 202 </summary>
<p>

[Git SCM - Lab 202](https://www.katacoda.com/aossama/scenarios/git-scm-lab-202)

В процессе выполнения сценария были использованы команды:

```
# Create new project; add CHANGELOG, LICENSE & CONTRIBUTING.md; add member to project
git clone http://git.itworx.cloud/Test/project-atomic.git . #Add files app.js package.json .gitignore
git add app.js package.json .gitignore
git commit -m "Add skeleton application"
git push #Create branch on project
git pull
git checkout feature-01 #Edit app.js
git commit -a -m "Add feature 1"
git push #Create a Merge request & Review, Approve and Merge
git checkout master
git pull #Create an Issue; Create a Merge request
git clone http://git.itworx.cloud/Test/project-atomic.git ./another-project-atomic/ #Edit another-project-atomic/app.js & Review, Approve and Merge
cd ../
git checkout master
git pull
```

</p>
</details>

---

<img src="../02Git/images/End.jpg" />