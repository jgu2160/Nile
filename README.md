# Nile
Run 'ruby connect_sets.rb' to fill 'out.csv' with the training data plus relevant weather and spray data.

Weather data populates one month behind and one month forward of the given date, using both weather stations.
Spray data populates one month behind, taking into account latitude and longitude, ignoring coordinates that fall outside how far a mosquito could migrate in the interim days.
