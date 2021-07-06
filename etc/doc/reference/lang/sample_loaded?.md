# Test if sample was pre-loaded

```
sample_loaded? 
 <!--- #tr -->path (string)<!--- #end tr -->
```


Given a path to a `.wav`, `.wave`, `.aif`, `.aiff`, `.ogg`, `.oga` or `.flac` file, returns `true` if the sample has already been loaded.

Introduced in v2.2

## Example

<table class="examples">
<tr>
<th colspan="2" class="even head"># Example 1 ──────────────────────────────────────────────────────</th>
</tr>
<tr>
<td class="even">

```ruby
load_sample :elec_blip
puts sample_loaded? :elec_blip
puts sample_loaded? :misc_burp



```

</td>
<td class="even">

<!--- #tr -->
```ruby
# :elec_blip is now loaded and ready to play as a sample
# prints true because it has been pre-loaded
# prints false because it has not been loaded



```
<!--- #end tr -->

</td>
</tr>
</table>

