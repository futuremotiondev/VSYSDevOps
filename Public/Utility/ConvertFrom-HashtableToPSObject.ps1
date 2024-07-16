function ConvertFrom-HashtableToPSObject {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.IDictionary] $HashTable
    )
    process {
        $OrderedHashtable = [ordered] @{}
        foreach ($Entry in $HashTable.GetEnumerator()) {
            if ($Entry.Value -is [System.Collections.IDictionary]) {
                # Nested dictionary? Recurse.
                # NOTE: Casting to [object] prevents problems with *numeric* hashtable keys.
                $OrderedHashtable[[object] $Entry.Key] = ConvertFrom-HashtableToPSObject -HashTable $Entry.Value
            } else {
                # Copy value as-is.
                $OrderedHashtable[[object] $Entry.Key] = $Entry.Value
            }
        }
        [PSCustomObject] $OrderedHashtable
    }
}