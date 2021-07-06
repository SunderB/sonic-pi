# Determine if note or args is a rest

```
rest? 
 <!--- #tr -->note_or_args (number_symbol_or_map)<!--- #end tr -->
```


Given a note or an args map, returns true if it represents a rest and false if otherwise

Introduced in v2.1

## Examples

<table class="examples">
<tr>
<th colspan="2" class="even head"># Example 1 ──────────────────────────────────────────────────────</th>
</tr>
<tr>
<td class="even">

```ruby
puts rest? nil



```

</td>
<td class="even">

<!--- #tr -->
```ruby
# true



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
puts rest? :r



```

</td>
<td class="odd">

<!--- #tr -->
```ruby
# true



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
puts rest? :rest



```

</td>
<td class="even">

<!--- #tr -->
```ruby
# true



```
<!--- #end tr -->

</td>
</tr>
<tr>
<th colspan="2" class="odd head"># Example 4 ──────────────────────────────────────────────────────</th>
</tr>
<tr>
<td class="odd">

```ruby
puts rest? 60



```

</td>
<td class="odd">

<!--- #tr -->
```ruby
# false



```
<!--- #end tr -->

</td>
</tr>
<tr>
<th colspan="2" class="even head"># Example 5 ──────────────────────────────────────────────────────</th>
</tr>
<tr>
<td class="even">

```ruby
puts rest? {}



```

</td>
<td class="even">

<!--- #tr -->
```ruby
# false



```
<!--- #end tr -->

</td>
</tr>
<tr>
<th colspan="2" class="odd head"># Example 6 ──────────────────────────────────────────────────────</th>
</tr>
<tr>
<td class="odd">

```ruby
puts rest? {note: :rest}



```

</td>
<td class="odd">

<!--- #tr -->
```ruby
# true



```
<!--- #end tr -->

</td>
</tr>
<tr>
<th colspan="2" class="even head"># Example 7 ──────────────────────────────────────────────────────</th>
</tr>
<tr>
<td class="even">

```ruby
puts rest? {note: nil}



```

</td>
<td class="even">

<!--- #tr -->
```ruby
# true



```
<!--- #end tr -->

</td>
</tr>
<tr>
<th colspan="2" class="odd head"># Example 8 ──────────────────────────────────────────────────────</th>
</tr>
<tr>
<td class="odd">

```ruby
puts rest? {note: 50}



```

</td>
<td class="odd">

<!--- #tr -->
```ruby
# false



```
<!--- #end tr -->

</td>
</tr>
</table>

