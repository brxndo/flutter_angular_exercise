import { ChangeDetectionStrategy, Component, computed, input, output } from '@angular/core';

import { PAGE_SIZE } from '../../core/api';

@Component({
  selector: 'app-paginator',
  templateUrl: './paginator.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PaginatorComponent {
  readonly page = input.required<number>();
  readonly total = input.required<number>();

  readonly pageChange = output<number>();

  protected readonly totalPages = computed(() => Math.max(1, Math.ceil(this.total() / PAGE_SIZE)));

  protected readonly from = computed(() =>
    this.total() === 0 ? 0 : (this.page() - 1) * PAGE_SIZE + 1,
  );

  protected readonly to = computed(() => Math.min(this.page() * PAGE_SIZE, this.total()));

  protected readonly canGoBack = computed(() => this.page() > 1);

  protected readonly canGoForward = computed(() => this.page() < this.totalPages());

  protected go(offset: number): void {
    this.pageChange.emit(this.page() + offset);
  }
}
