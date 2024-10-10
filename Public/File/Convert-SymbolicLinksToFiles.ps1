function Convert-SymbolicLinksToFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.IO.FileInfo[]] $Files,
        [Switch] $ProcessImagesOnly,
        [Switch] $PrefixContainingFolderName
    )

    $LeafSymlinks   = [System.Collections.Generic.List[Object]]@()
    $DirSymlinks    = [System.Collections.Generic.List[Object]]@()
    $DirNonSymlinks = [System.Collections.Generic.List[Object]]@()

    foreach ($File in $Files) {

        $FileInfoObject = Get-Item -LiteralPath $File
        if(Test-Path -LiteralPath $FileInfoObject.FullName -PathType Container) {

            Remove-EmptyDirectories -Directories $FileInfoObject.FullName

            if ($FileInfoObject.LinkType) {
                $DirSymlinks.Add($FileInfoObject)
            } else {
                $Contents = Get-ChildItem -LiteralPath $FileInfoObject -Recurse -Depth 10
                foreach ($Item in $Contents) {
                    if ($Item.LinkType) {
                        if (Test-Path -LiteralPath $Item.FullName -PathType Container) {
                            $DirSymlinks.Add($Item)
                        }
                        elseif (Test-Path -LiteralPath $Item.FullName -PathType Leaf) {
                            if ($ProcessImagesOnly) {
                                $ValidImageExtensions = @(".svg", ".jpg", ".jpeg", ".png", ".webp", ".tif", ".tiff", ".bmp", ".gif")
                                if ($ValidImageExtensions -contains ([System.IO.Path]::GetExtension($Item.FullName).ToLower())) {
                                    $LeafSymlinks.Add($Item)
                                }
                            } else {
                                $LeafSymlinks.Add($Item)
                            }
                        }
                    } else {
                        $DirNonSymlinks.Add($Item)
                    }
                }
            }
        } elseif (Test-Path -LiteralPath $FileInfoObject.FullName -PathType Leaf) {
            if ($FileInfoObject.LinkType) {
                $LeafSymlinks.Add($FileInfoObject)
            }
        }
    }

    if($DirSymlinks){
        Resolve-SymbolicLinks -SymlinkList $DirSymlinks
    }
    if($LeafSymlinks){
        $resolveSymbolicLinksSplat = @{
            SymlinkList = $LeafSymlinks
            PrefixContainingFolderName = $PrefixContainingFolderName
        }
        Resolve-SymbolicLinks @resolveSymbolicLinksSplat
    }

    if($DirNonSymlinks){
        foreach ($I in $DirNonSymlinks) {
            if (Test-Path -LiteralPath $I.FullName -PathType Container) {
                Remove-EmptyDirectories -Directories $I.FullName
            }
        }
    }

}