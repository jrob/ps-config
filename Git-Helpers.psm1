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

export-modulemember -function Add-GitSplitBranches
export-modulemember -function Clear-GitSplitBranches
