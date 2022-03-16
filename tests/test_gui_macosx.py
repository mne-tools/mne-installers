import matplotlib.pyplot as plt

# Matplotlib default (MacOSX)
fig, _ = plt.subplots()
want = ' NSView '
assert want in repr(fig.canvas), repr(fig.canvas)
plt.close('all')
