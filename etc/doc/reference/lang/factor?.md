# Factor test

```
factor? 
 <!--- #tr -->val (number), factor (number)<!--- #end tr -->
```


Test to see if factor is indeed a factor of `val`. In other words, can `val` be divided exactly by factor.

Introduced in v2.1

## Examples

<table class="examples">
<tr>
<th colspan="2" class="even head"># Example 1 ──────────────────────────────────────────────────────</th>
</tr>
<tr>
<td class="even">

```ruby
factor?(10, 2)



```

</td>
<td class="even">

<!--- #tr -->
```ruby
# true - 10 is a multiple of 2 (2 * 5 = 10)



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
factor?(11, 2)



```

</td>
<td class="odd">

<!--- #tr -->
```ruby
#false - 11 is not a multiple of 2



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
factor?(2, 0.5)



```

</td>
<td class="even">

<!--- #tr -->
```ruby
#true - 2 is a multiple of 0.5 (0.5 * 4 = 2)



```
<!--- #end tr -->

</td>
</tr>
</table>

