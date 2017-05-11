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

function Move-FormatCommit($formattingbranch, $targetbranch, $testbranch)
{
    git checkout $targetbranch
    git branch -D format-branch-temp
    git branch -D format-branch-rebase-temp

    git branch format-branch-temp $targetbranch
    $revlist = git rev-list "$targetbranch..$formattingbranch"
    
    [array]::Reverse($revlist)

    git checkout format-branch-temp

    #for($i=0; $i -le 4; $i++)
    for($i=0; $i -le $revlist.Count; $i++)
    {
        $ref = $revlist[$i]
        write-host $ref
        git cherry-pick $ref
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
            git checkout -b format-branch-rebase-temp $testbranch
            git rebase format-branch-temp
            if(test-path .git/rebase-apply)
            {
                $failedfiles = git diff --name-only --diff-filter=U
                git rebase --abort
                git checkout format-branch-temp
                git reset --mixed head^
                foreach ($file in $failedfiles)
                {
                    Write-Host "reset $file"
                    $lastcommitmsg += "`n$file"
                    git checkout -- $file
                }
                git add .
                git commit -m $lastcommitmsg
            }
            else
            {
                $checkForMergeConflicts = $false
            }

            git checkout format-branch-temp
            git branch -D format-branch-rebase-temp
        }
    }
}

export-modulemember -function Add-GitSplitBranches
export-modulemember -function Clear-GitSplitBranches
export-modulemember -function Move-FormatCommit
