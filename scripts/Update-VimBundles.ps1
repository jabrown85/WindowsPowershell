pushd ~/dev/dotfiles/vim/bundle

ls | foreach {
    pushd $_

    Write-Host "`nUpdating $([System.IO.Path]::GetFileName($_))..."

    git co master
    git pull

    popd
}

popd
