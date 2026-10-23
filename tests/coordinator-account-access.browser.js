// Run against a disposable test host with coordinator-one, s1 and a1 fixture accounts.
async page => {
 const base = 'http://localhost:57995', db = 'http://127.0.0.1:18771/firebase';
 let checks = 0;
 const check = (ok, message) => { if (!ok) throw Error(message); checks++; };
 const read = async path => (await page.request.get(db + '/' + path + '.json')).json();
 const visit = async name => {
  const response = await page.goto(base + '/Pages/Coordinator/' + name + '.aspx');
  check(response.ok(), name + ' renders successfully');
 };
 const row = email => page.locator('tr').filter({hasText: email}).filter({visible: true});
 async function decide(button, accept, word) {
  let message;
  page.once('dialog', async dialog => {
   message = dialog.message();
   if (accept) await dialog.accept(); else await dialog.dismiss();
  });
  if (accept) {
   const [response] = await Promise.all([page.waitForNavigation(), button.click()]);
   check(response.ok(), 'Access change completes without a server error');
  }
  else await button.click();
  check(message && message.includes(word), 'Confirmation describes ' + word);
  return message;
 }
 await page.goto(base + '/__fixture.aspx?user=coordinator-one');
 for (const [name, id, email] of [
  ['Students', 's1', 's1@example.test'],
  ['ManageStudents', 's1', 's1@example.test'],
  ['AcademicSupervisors', 'a1', 'one@example.test']
 ]) {
  await visit(name);
  const account = row(email);
  const before = await read('users/' + id);
  const prompt = await decide(account.getByRole('link', {name:'Block', exact:true}), false, 'block');
  check(prompt.includes(before.FullName), name + ' confirms the selected name including punctuation');
  check((await read('users/' + id)).IsActive, name + ' cancellation preserves access');
  await decide(account.getByRole('link', {name:'Block', exact:true}), true, 'block');
  const blocked = await read('users/' + id);
  check(!blocked.IsActive, name + ' blocks the account');
  check(blocked.FullName === before.FullName && blocked.Email === before.Email,
   name + ' preserves account information');
  if (name !== 'Students') await page.locator('#pnlDetails .btn-close').click();
  check((await row(email).innerText()).includes('Blocked'), name + ' shows Blocked status');
  await decide(row(email).getByRole('link', {name:'Unblock', exact:true}), true, 'unblock');
  check((await read('users/' + id)).IsActive, name + ' restores access');
  if (name !== 'Students') await page.locator('#pnlDetails .btn-close').click();
 }
 for (const [name, id, email] of [
  ['ManageStudents', 's1', 's1@example.test'],
  ['AcademicSupervisors', 'a1', 'one@example.test']
 ]) {
  await visit(name);
  await row(email).getByRole('link', {name:'Manage', exact:true}).click();
  const modal = page.locator('#pnlDetails');
  await decide(modal.getByRole('button', {name:'Block', exact:true}), false, 'block');
  check((await read('users/' + id)).IsActive, name + ' modal cancellation preserves access');
  await decide(modal.getByRole('button', {name:'Block', exact:true}), true, 'block');
  check(!((await read('users/' + id)).IsActive), name + ' modal blocks');
  await decide(modal.getByRole('button', {name:'Unblock', exact:true}), true, 'unblock');
  check((await read('users/' + id)).IsActive, name + ' modal unblocks');
  await modal.locator('.btn-close').click();
 }
 await visit('AcademicSupervisors');
 await page.getByRole('tab', {name:'Manage supervisors', exact:true}).click();
 check(await row('one@example.test').getByRole('link', {name:'Block', exact:true}).isVisible(),
  'Supervisor manage tab includes Block');
 await page.context().addCookies([{name:'uims-lang', value:'ar', url:base}]);
 await visit('Students');
 await decide(row('s1@example.test').getByRole('link', {name:'حظر', exact:true}), false, 'حظر');
 check((await read('users/s1')).IsActive, 'Arabic cancellation preserves access');
 await page.context().clearCookies();
 return {checks};
}
