function Get-CurrentRefs($branch)
{
    #git log --ancestry-path --simplify-by-decoration --oneline --decorate "^$branch" --all --graph
    $revs = git rev-list --ancestry-path --simplify-by-decoration "^$branch" --all
    return $revs
}

function Clear-GitSplitBranches()
{
    $branches = @(git branch) -match 'split-*'
    foreach ($branch in $branches)
    {
        $branch = $branch.trim()
        git branch -D $branch
    }
}

function Add-GitSplitBranches($branch)
{
    Clear-GitSplitBranches $branch
    $splits = @()
    $refs = Get-CurrentRefs $branch
    $count = $refs.Count
    Write-Host "Checking" ($count * $count) "combinations."
    for($i=0; $i -lt $count -1; $i++){
        $a = $refs[$i]
        for($j=$i+1; $j -lt $count; $j++){
            $b = $refs[$j]
            $splits += git merge-base $a $b
        }
    }
    $splits = ($splits | Sort-Object | Get-Unique -AsString)
    $num = 1
    for($i=1; $i -le $splits.Count; $i++){
        $ref = $splits[$i-1]
        $currentbranchs = git log -1 --oneline --pretty=format:%d $ref
        if ($currentbranchs) { continue }
        git branch split-$num $ref
        $num++
    }
}

function Move-FormatCommit($basebranch, $formatbranch, $outbranch, $testbranch)
{
    Write-Host "-------------------------------------------------------------"
    Write-Host "-------------------------------------------------------------"
    Write-Host "Creating $outbranch using $formatbranch and testing with $testbranch"

    git branch -D $outbranch *>$null
    git checkout -b $outbranch $basebranch *>$null
    git branch -D format-branch-rebase-temp *>$null

    $revlist = git rev-list "$outbranch..$formatbranch"
    
    [array]::Reverse($revlist)

    #for($i=0; $i -le 1; $i++)
    for($i=0; $i -lt $revlist.Count; $i++)
    {
        $ref = $revlist[$i]
        Write-Host "`n-------------------------------------------------------------"
        git cherry-pick $ref 1>$null
        git log -1 --oneline

        $checkForMergeConflicts = $true
        while ($checkForMergeConflicts)
        {
            $lastcommitmsg = git log -1 --pretty=%B
            $lastcommitmsg = ($lastcommitmsg -join "`n").trim()
            if (($lastcommitmsg | measure-object -line).Lines -eq 1)
            { 
                $lastcommitmsg += "`n`nFiles not formatted:"
            }
            Write-Host $lastcommitmsg
            git checkout -b format-branch-rebase-temp $testbranch *>$null
            git rebase $outbranch *>$null
            if(test-path .git/rebase-apply)
            {
                $failedfiles = git diff --name-only --diff-filter=U
                git rebase --abort *>$null
                git checkout $outbranch *>$null
                git reset --mixed head^ *>$null
                foreach ($file in $failedfiles)
                {
                    Write-Host "reset $file"
                    $lastcommitmsg += "`n$file"
                    git checkout -- $file *>$null
                }
                git add . 1>$null
                git commit -m $lastcommitmsg *>$null
            }
            else
            {
                $checkForMergeConflicts = $false
            }

            git checkout $outbranch *>$null
            git branch -D format-branch-rebase-temp *>$null
        }
    }
}

function Move-MultipleBranchesWithRebase($target, $branches)
{
    foreach ($branch in $branches)  
    {
        $localbranch = $branch
        if ($branch.Contains("/"))
        {
            $localbranch = $branch.split("/")[1]
            git branch $localbranch $branch
        }
        git checkout $localbranch
        git rebase $target $localbranch
        Write-Host ""
    }
}

export-modulemember -function Add-GitSplitBranches
export-modulemember -function Clear-GitSplitBranches
export-modulemember -function Move-FormatCommit
export-modulemember -function Move-MultipleBranchesWithRebase
