<template>
  <ul class="tu-test-suite"><slot></slot></ul>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'tu-test-suite'
})
</script>

<style>
.tu-test-suite {
  font-size: 12px;
  list-style-type: none;
  padding: 0;
  margin: 0;
}
.tu-test-suite ul {
  list-style-type: none;
  padding-left: 18px;
}

.tu-test-suite .tu-passed > .tu-title
{
  background-image: url(../images/accept.svg);
}

.tu-test-suite .tu-failed > .tu-title
{
  background-image: url(../images/exclamation.svg);
}

.tu-test-suite .tu-error > .tu-title
{
  background-image: url(../images/error.svg);
}

.tu-test-suite .tu-skipped > .tu-title
{
  background-image: url(../images/skip.svg);
}

.tu-test-suite .tu-missing > .tu-title
{
  background-image: url(../images/missing.svg);
}

/* Partially missing testcases */
.tu-test-suite .tu-missing.tu-passed > .tu-title
{
  background-image: url(../images/missing_accept.svg);
}
.tu-test-suite .tu-missing.tu-failed > .tu-title
{
  background-image: url(../images/missing_exclamation.svg);
}
.tu-test-suite .tu-missing.tu-error > .tu-title
{
  background-image: url(../images/missing_error.svg);
}
.tu-test-suite .tu-missing.tu-partial > .tu-title
{
  background-image: url(../images/missing_not_run.svg);
}
</style>
