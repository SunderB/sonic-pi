# Determine if block contains sleep time

```
block_slept? 
 <!--- #tr --><!--- #end tr -->
```


Given a block, runs it and returns whether or not the block contained sleeps or syncs

Introduced in v2.9

## Examples

<table class="examples">
<tr>
<th colspan="2" class="even head"># Example 1 ──────────────────────────────────────────────────────</th>
</tr>
<tr>
<td class="even">

```ruby
slept = block_slept? do
  play 50
  sleep 1
  play 62
  sleep 2
end

puts slept



```

</td>
<td class="even">

<!--- #tr -->
```ruby
 
 
 
 
 
 
 
#=> Returns true as there were sleeps in the block



```
<!--- #end tr -->

</td>
</tr>
<tr>
<th colspan="2" class="odd head"># Example 2 ──────────────────────────────────────────────────────</th>
</tr>
<tr>
<td class="odd">

```ruby
in_thread do
  sleep 1
  cue :foo 
end

slept = block_slept? do
  sync :foo 
  play 62
end

puts slept



```

</td>
<td class="odd">

<!--- #tr -->
```ruby
 
 
# trigger a cue on a different thread
 
 
 
# wait for the cue before playing the note
 
 
 
#=> Returns true as the block contained a sync.



```
<!--- #end tr -->

</td>
</tr>
<tr>
<th colspan="2" class="even head"># Example 3 ──────────────────────────────────────────────────────</th>
</tr>
<tr>
<td class="even">

```ruby
slept = block_slept? do
  play 50
  play 62
end

puts slept



```

</td>
<td class="even">

<!--- #tr -->
```ruby
 
 
 
 
 
#=> Returns false as there were no sleeps in the block



```
<!--- #end tr -->

</td>
</tr>
</table>

