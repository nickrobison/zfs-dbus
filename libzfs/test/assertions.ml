
let non_empty ?here:_ ?pos:_ ~msg value = 
  if (String.length value == 0) then 
    Alcotest.failf "Expected `%s` to be non-empty. %s" value msg

let gte ?here:_ ?pos:_ msg expected value = 
  if not (value >= expected) then
    Alcotest.failf "Expected `%d` to be greater than, or equal to `%d`. %s" value expected msg